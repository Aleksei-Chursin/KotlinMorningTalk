# Speaker Notes - Kotlin for Java Developers

## Slide 1: Welcome

Good morning. 
Today's morning talk is about Kotlin for Java developers. We'll focus on practical Kotlin features rather than philosophical discussions about why you should or shouldn't use it. I want to show you tangible examples of how Kotlin makes your code better and helps you ship faster.

This talk is designed for Java developers with a couple years of experience who are either considering Kotlin for their team or just curious about what makes it different. We'll cover 9 topics in about an hour, and each one represents a concrete feature you can start using in your own projects right away.

---

## Slide 2: About Me

My name is Aleksei. I've been working with Java for over 5 years. Right now I'm at Deutsche Börse working on an intraday power trading system that processes more than 30 million requests every day.

I work a lot with reactive programming - Kotlin Flows, coroutines, WebFlux, and we will also dive into concurrency today.

Everything you'll see in this talk comes from my production experience: actual patterns i use, the tradeoffs i've made, and the kinds of decisions you face when building systems that need to handle serious load.

---

## Slide 3: Today's Plan

Let me walk you through what we'll cover. The first three topics are about Kotlin syntax - getting rid of Java ceremony, understanding null safety, and working with data more effectively. Topics four through six focus on Kotlin features that help keep your code clean. The last three are more practical - concurrency, framework choices, and the ecosystem tools that are existing for Kotlin.

I'll try to keep this hands-on. For each topic, I'll show you a problem and how Kotlin solves it, sometimes with a Java comparison so you can see the differences clearly.

---

## Slide 4-6: The "Unlearning" Phase

When you start with Kotlin, there are a few Java habits you need to unlearn. 
First are Semicolons - they are now optional - you can just leave them off. 
Second is The `new` keyword - it doesn't exist - you call constructors directly. 
And you don't need static methods everywhere - top-level functions work just fine.

These might seem like small things for now, but you will notice how they add up. 
When you're working with a codebase that has thousands of files, every line of boilerplate you can remove is a line you don't have to read, test, or maintain later.

When working with high-performance requirements, I've found that Kotlin's top-level functions and inline functions actually help with performance. 
Top-level functions compile directly to static methods without any class wrapper overhead - no extra class instantiation to worry about.

Inline functions are particularly interesting for performance-critical code. 
The compiler copies the function body directly to the call site instead of doing a function call. This means no stack frame setup, no register spilling, no return jump. The JIT compiler can see the whole inlined code as a single unit and apply optimizations like loop unrolling and SIMD that wouldn't be possible across function boundaries. This matters a lot when you have filtering functions being called millions of times per second.

---

## Slide 7-10: Null Safety - The Real Power

Let me talk about null safety, because this is where Kotlin really differs from Java. In Java, we have Optional as a library solution, but in Kotlin, null safety is built into the type system itself.

Here's the key difference: in Kotlin, `String` and `String?` are actually different types at compile time. The compiler enforces this distinction, so you can't accidentally use a nullable value where a non-null one is expected.

This matters because when we look at production bugs in Java systems, a huge portion of them are null-related. In our trading platform, the code handling 30 million requests per day uses patterns like the Elvis operator for early returns. When you write `sendingContext ?: return`, you get a single efficient null check that compiles to clean bytecode without nested branches.

The compiler does something interesting here called smart casting. After you check that a value isn't null, the compiler knows that for the rest of that scope, and it treats it as a non-null type. This means zero runtime overhead for accessing that value afterward - the compiler has already proven it's safe.

What this gives us in practice: we've measured zero NullPointerExceptions coming from our Kotlin code in production, while our legacy Java services still see dozens of NPEs every month. The type-level null safety eliminates runtime null checks in hot code paths, which means fewer branch instructions and better CPU branch prediction.

The `?.let { }` pattern is particularly useful for optional fields. When you're building objects where some fields might be present or not, you write one concise line instead of an if-not-null block. Compare that to Java where you'd write explicit if-not-null checks or chain Optional methods.

---

## Slide 11-13: Data Classes & Properties

Data classes are one of those features that seems simple on the surface but actually changes how you approach modeling your domain.

Let me show you a real example from our system. We have this `OutboundServiceState` that's used across 15 different services when they're handling concurrent requests. It's a generic container that holds internal state and tracks sequences for different message types.

Because this data class is immutable - all the fields are `val` - we don't need any locks for concurrent reads across services. Different threads can safely read this state without any synchronization overhead because nobody can mutate it.

The `copy()` method is what makes immutability practical. When you need to update the state, you create a new instance with just the fields you want to change. So `state.copy(sequences = newMap)` gives you a new object where only the sequences map is different - everything else is exactly the same.

Here's what makes this efficient: the copy operation doesn't actually clone everything. It only allocates new memory for the changed fields, while unchanged fields just share references to the existing data. We've measured this and it uses about 40% of the memory compared to doing a full deep clone.

The alternative in Java is either using mutable POJOs, which requires synchronized blocks and creates lock contention when you have concurrent access, or implementing the builder pattern, which typically runs to 30 or more lines of code. Meanwhile the Kotlin data class is 5 lines that give you the constructor, equals, hashCode, toString, and copy methods automatically.

When we looked at our codebase, we estimated about 83% code reduction for data models - what would be 3,000 lines of Java is about 500 lines of Kotlin. Java Records in version 14 and later get close to this, but they still don't have the copy method.

---

## Slide 14-16: Smart Casting

Let me show you how we model events in our trading platform. We have this hierarchy called `GWOutputEvent` that's implemented as a sealed class, and it has three subtypes: OrderMessageGWOutputEvent for actual orderbook messages, HeartBeatGWOutputEvent for keepalive signals, and SnapshotGWOutputEvent for bulk snapshot data.

Sealed classes provide exhaustive checking at compile time. When you use a `when` expression with a sealed class, the compiler forces you to handle all possible cases. If you add a new event type later, every single `when` expression becomes a compile error until you update it to handle the new case.

Let me give you a concrete example from our experience. When we added trade confirmations as a new event type, the compiler immediately flagged 47 different locations in our codebase that needed to handle it. All of these were caught at compile time - the build simply failed until we fixed them. If we'd been using the traditional Java approach with abstract classes and instanceof checks, those would have been 47 potential runtime errors that we might not have discovered until they hit production.

Each branch of the when expression also knows exactly what type it's working with. There's no casting needed - the compiler has already figured out the type for you.

Sealed classes are also more flexible than enums because each subclass can have its own unique properties. Enums can't do that - they can only carry data that's common to all values.

Java 17 and later do have sealed classes, though they require an explicit permits clause. Java 21 added pattern matching in switch statements. But before Java 17, you were stuck with abstract classes and manual instanceof checks with no compiler help for exhaustiveness.

---

## Slide 17-19: Feature Mapping

Java has the Stream API with operations like map, filter, and collect. These use eager evaluation, meaning they build intermediate lists for each operation. Kotlin has Sequences that use the same patterns but with lazy evaluation - the operations are only computed when you actually need the result.

For small lists, the difference doesn't matter much. But when you're working with large datasets or building processing pipelines, lazy evaluation with Sequences can be significantly more efficient.

Destructuring is a syntax feature that lets you unpack objects. You can write `val (id, name) = user` and it unpacks the object in a single line, which is particularly useful when working with data classes.

---

## Slide 20-23: Functional Idioms

Extension functions let you add methods to existing classes without modifying their source code or using inheritance. This is particularly useful when you're working with classes you don't own.

We use Protobuf heavily for our gRPC services, and we've created extensions like `Long.toTimestamp()` that converts Unix milliseconds to Protobuf Timestamp format. In Java you'd need a utility class, so you'd write something like `ProtobufUtil.longToTimestamp(System.currentTimeMillis())`. With the extension function, it becomes `System.currentTimeMillis().toTimestamp()`.

Beyond shorter code, when you type a Long and hit dot in your IDE, the toTimestamp extension shows up in autocomplete. You don't need to remember which utility class contains which methods. The extensions are also scoped by import, so there's no namespace pollution.

For domain model conversions, we have multiple API versions - v5, v6, v7. Extension functions like `Order.asV7Order()` and `Collection<Order>.asOrderSnapshot()` let you chain conversions in a single expression. You can write something like `orders.filter { it.isActive }.map { it.asV7Order() }.asOrderSnapshot(123L)` and it reads left to right. The Java equivalent would require nested utility calls or temporary variables.

We've measured about 50% less code compared to using Java utility classes, and the code flows in a left-to-right direction that matches how you think about the transformation pipeline. Extension functions come up frequently when teams talk about why they adopted Kotlin - it's one of those features that once you start using, you really miss when you go back to Java.

---

## Slide 24-26: Concurrency Reimagined

The `GWOrderService` I'm showing you is a real production service that streams orderbook data to traders in real time. Clients subscribe to get market data updates - they receive an initial snapshot, then continuous updates as the market changes, with heartbeats to keep the connection alive. This handles thousands of concurrent subscriptions.

Coroutines provide several technical advantages here. First, the code structure is sequential even though execution is asynchronous. When you write `suspend fun subscribe` that returns a `Flow<OrderMessage>`, it looks like a regular function returning a collection, but the suspend keyword and Flow type make it fully asynchronous and capable of streaming data over time.

The Flow automatically handles backpressure. If a client is processing data slowly, the Flow applies backpressure without you writing any additional buffering logic. The compiler also verifies the types flowing through the stream, so you know at compile time that you're working with OrderMessage objects.

In Java gRPC, you implement this with StreamObserver, which is callback-based. You manually call onNext, onError, and onCompleted. You have to track subscriptions yourself for cleanup and handle error propagation explicitly across callbacks.

With Kotlin coroutines, errors propagate through exceptions using the standard try-catch mechanism. Completion is automatic when the Flow completes. Cancellation is automatic when the client disconnects. There's no manual subscription tracking needed - no map of subscription IDs to disposable objects.

The performance characteristics are interesting. Each coroutine uses roughly 100 bytes when suspended, compared to about 1 megabyte for a Java thread. That's a 10,000x difference in memory usage. Our system handles more than 10,000 concurrent gRPC streams on just 4 CPU cores, using less than 1 gigabyte of memory for all subscriptions. A thread-per-connection model would require at least 10 gigabytes and would need about 2,500 threads per core, creating massive context switching overhead.

We've measured about 50% less code compared to the Java equivalent because we don't need StreamObserver callbacks or manual lifecycle management. Coroutines provide a more maintainable async programming model than CompletableFuture, and the performance is comparable to Java 21's Virtual Threads while working on any JVM version.

---

## Slide 27-29: The Framework Decision

The `GWOrderService` constructor shows how Spring dependency injection works in Kotlin. You define properties directly in the constructor - no separate field declarations, no manual assignments. What would be 20 lines in Java becomes 7 lines in Kotlin. 

You can also provide default parameters right in the constructor, like `channelBufferSize = 1_000`. This means you don't need method overloading for optional dependencies. All the properties are `val`, which makes them final - immutability is enforced by the language. Lambda parameters like `(OrderMessage) -> Unit` work directly in Kotlin's type system without requiring functional interfaces.

There's one thing to be aware of with Spring and Kotlin: Kotlin classes are final by default, but Spring needs classes to be open for CGLIB proxies. The solution is the kotlin-spring compiler plugin, which automatically makes classes with Spring annotations open. You can also use the open keyword manually or switch to interface-based proxies.

At Deutsche Börse, we use Spring Boot because we need the extensive ecosystem - Spring Data, Spring Security, all of that. The team already knows Spring, and we value the enterprise support.

For new microservices though, it's worth evaluating Ktor. Ktor is designed with coroutines as a first-class concept from the ground up, whereas Spring Boot added coroutine support later. In Ktor, you write your handlers directly as suspend functions and return Flow types without any wrappers. In Spring WebFlux with coroutines, you need to use specific annotations and sometimes wrap reactive types - the framework was built for Reactor first, coroutines second.

Ktor also has less framework overhead - faster startup times and a smaller memory footprint. For a simple microservice that's mostly routing requests and calling other services, you don't need all of Spring's features, and Ktor's simpler architecture means there are fewer abstraction layers to go through.

The way I think about the choice: use Spring when you're building enterprise applications that need ecosystem integration - database access, security, message queues - and you have existing Spring knowledge on the team. Consider Ktor for focused microservices where you want a lighter framework and you're building a service that's heavily async with coroutines from top to bottom.

---

## Slide 30-32: Ecosystem Recommendations

For testing, MockK is designed specifically for Kotlin and supports all Kotlin features like data classes and extensions. It handles Kotlin-specific features that Mockito struggles with, like suspend functions and inline classes.

Koin is a lightweight dependency injection library with no reflection magic - it's compile-time safe and straightforward to use.

If you want functional programming in the style of Scala, Arrow provides types like Either, Option, and effect handling.

Other tools worth knowing about: Exposed for type-safe SQL, kotlinx.serialization for compile-time JSON handling, and of course the Coroutines library itself for reactive streams with Flow.

The ecosystem is mature and production-ready. You're not pioneering uncharted territory here.

---

## Slide 33: Key Takeaways

Let me summarize the key points. Null safety at the type level eliminates NullPointerExceptions - we've seen zero NPEs from Kotlin code in production while our legacy Java services still see them monthly.

We're seeing 40 to 50 percent less code overall. Data classes give us 83% reduction, dependency injection configuration is 65% less code, and null handling is 43% less compared to Java.

Extension functions improve how you organize code with better discoverability and natural method chaining. Coroutines and Flow provide a simpler async programming model - about 50% less code than Java and more maintainable than CompletableFuture, with performance comparable to Java 21's Virtual Threads.

Sealed classes turn potential runtime bugs into compile-time errors through exhaustive checking. We've proven this at production scale handling more than 30 million requests per day with over 10,000 concurrent gRPC streams.

Spring Boot integration is mature with first-class support - just remember to use the kotlin-spring compiler plugin to handle the final class issue.

The learning curve is typically 2 to 4 weeks, and teams generally report productivity improvements after that initial ramp-up.

Looking at our specific metrics: we saved about 20,000 lines of code, which is a measured 40% reduction across the codebase. We can handle 10,000 concurrent subscriptions on 4 CPU cores, which would be about 400 max with thread-per-connection in Java. Memory efficiency is under 1 gigabyte for our subscriptions versus the roughly 10 gigabytes that would be required for an equivalent thread-based Java implementation. We estimate we saved 6 to 9 months of development time compared to a full Java rewrite.

The bottom line is that Kotlin provides measurable improvements in code quality, reduces maintenance burden, and increases system reliability. The trading platform case study I've shown you demonstrates that this works in production under demanding requirements.

Regarding the learning investment: that 2 to 4 week learning curve results in 40% less code to maintain long-term, and teams typically see productivity gains after the initial ramp-up period.

---

## Slide 34: Questions?

I'm happy to dive deeper into any of these topics, discuss specific tradeoffs you might be considering, or talk about how Ktor versus Spring Boot might work for your particular deployment needs. Thanks for your time.
