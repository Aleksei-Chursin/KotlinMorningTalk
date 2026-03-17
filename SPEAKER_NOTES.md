# Speaker Notes - Kotlin for Java Developers

## Slide 1: Welcome

Good morning. 
Today's morning talk is about Kotlin for Java developers. We'll focus on practical Kotlin features rather than philosophical discussions about why you should or shouldn't use it. I want to show you tangible examples of how Kotlin makes your code better and helps you ship faster.

This talk is designed for Java developers with a couple years of experience who are either considering Kotlin for their team or just curious about what makes it different. We'll cover 11 topics in about an hour, and each one represents a concrete feature you can start using in your own projects right away.

---

## Slide 2: About Me

My name is Aleksei. I've been working with Java for over 5 years. Right now I'm at Deutsche Börse working on an intraday power trading system that processes more than 30 million requests every day.

I work a lot with reactive programming - Kotlin Flows, coroutines, WebFlux, and we will also dive into concurrency today.

Everything you'll see in this talk comes from my production experience: actual patterns i use, the tradeoffs i've made, and the kinds of decisions you face when building systems that need to handle serious load.

---

## Slide 3: Today's Plan

Let me walk you through what we'll cover. 

There are many Kotlin features we will not cover - inline classes, contracts, context receivers, delegation, type aliases, DSL builders, and more. The goal of this talk is to focus on the features that provide the most immediate practical value when transitioning from Java. You can think of this as 20% of Kotlin features that you'll use 80% of the time.

I've organized the content into three blocks. Block 1 is about Syntax & Safety - getting rid of Java ceremony with features like null safety and data classes. Block 2 covers Functional & Expressive features - things like functional programming support, operator overloading, and extension functions that make your code cleaner. Block 3 is Practical - concurrency with coroutines, framework choices, and ecosystem tools. Finally, I'll share some learning resources to help you get started.

I'll try to keep this hands-on. For each topic, I'll show you a problem and how Kotlin solves it, sometimes with a Java comparison so you can see the differences clearly.

---

## Slide 4-6: The "Unlearning" Phase

When you start with Kotlin, there are a few Java habits you need to unlearn. 
First are Semicolons - they are now optional - you can just leave them off. 

Before we go further, let me explain something you'll see everywhere in Kotlin code: `val` and `var`. In Kotlin, `val` declares an immutable reference - think of it like `final` in Java. Once you assign a value, you can't reassign it. `var` declares a mutable reference - you can reassign it later. The Kotlin convention is to default to `val` and only use `var` when you actually need mutability. This encourages immutability, which makes concurrent code safer and easier to reason about.

Second is The `new` keyword - it doesn't exist - you call constructors directly. 
And you don't need static methods everywhere - top-level functions work just fine.

These might seem like small things for now, but you will notice how they add up. We all know that code comprehension time increases non-linearly with boilerplate - every unnecessary character requires mental processing. In codebases with thousands of files, reducing visual noise helps developers focus on business logic rather than language syntax.

When you're working with a codebase that has thousands of files, every line of boilerplate you can remove is a line you don't have to read, test, or maintain later.

Personally, when working with high-performance requirements, I've found that Kotlin's top-level functions and inline functions actually help with performance. 
Top-level functions compile directly to static methods without any class wrapper overhead - no extra class instantiation to worry about.

Inline functions are particularly interesting for performance-critical code.

Kotlin's `inline` keyword forces the compiler to copy the function's bytecode directly to the call site at compile time. Java can also inline methods, but only at runtime through JIT compilation based on hotspot analysis. The key difference with Kotlin is that inline functions eliminate lambda allocations entirely - when you pass a lambda to an inline function, the lambda's code is also inlined, avoiding object allocation. For example, `list.filter { it > 5 }` normally creates a Function object for the lambda, but if filter is inline, no object is created.

This matters for higher-order functions called frequently. In our high-frequency system, when filtering thousands of items per second, avoiding lambda allocations reduces GC pressure. The JIT compiler can then optimize the inlined code as a single block - including loop unrolling and SIMD vectorization - but the inline keyword ensures this happens by eliminating the abstraction overhead upfront.

---

## Slide 7-10: Null Safety - The Real Power

Let me talk about null safety, because this is where Kotlin really differs from Java. In Java, we have Optional as a library solution, but in Kotlin, null safety is built into the type system itself.

Here's the key difference: in Kotlin, `String` and `String?` are actually different types at compile time. The compiler enforces this distinction, so you can't accidentally use a nullable value where a non-null one is expected.

This matters because when we look at production bugs in Java systems, a huge portion of them are null-related. 
Kotlin allows you to use patterns like the Elvis operator for early returns. When you write `sendingContext ?: return`, you get a single efficient null check that compiles to clean bytecode without nested branches.

The compiler does something interesting here called smart casting. 
After you check that a value isn't null, the compiler knows that for the rest of that scope, and it treats it as a non-null type. This means zero runtime overhead for accessing that value afterward - the compiler has already proven it's safe.

What this gives us in practice: 

The type-level null safety eliminates runtime null checks in hot code paths, which means fewer branch instructions. There is a thing called CPU branch prediction, and it basicaly works by guessing which path a conditional branch will take. 

When you have defensive null checks scattered throughout code, the CPU's branch predictor must track more branches, and mispredictions cause pipeline stalls. Kotlin's type system eliminates many branches at compile time because the compiler has already proven values are non-null, reducing the total number of branches the CPU needs to predict.

The `?.let { }` pattern is particularly useful for optional fields. The `let` function takes the non-null value and passes it to a lambda, executing the block only when the value isn't null. Under the hood, this compiles to the same bytecode as an if-not-null check, but the scoping is cleaner - the lambda parameter shadows the outer variable, making it impossible to accidentally use the nullable reference inside the block. When you're building objects where some fields might be present or not, you write one concise line instead of an if-not-null block. Compare that to Java where you'd write explicit if-not-null checks or chain Optional methods.

---

## Slide 11-13: Data Classes & Properties

Data classes are one of those features that seems simple on the surface but actually changes how you approach modeling your data structures and business entities.

Let me show you a real example from our system. We have this `ServiceState` that's used across 15 different services when they're handling concurrent requests. It's a generic container that holds internal state and tracks sequences for different message types.

Because this data class is immutable - all the fields are `val` - we don't need any locks for concurrent reads across services. Different threads can safely read this state without any synchronization overhead because nobody can mutate it.

In Java, you'd either create a mutable POJO with synchronized getters and setters (adding lock contention overhead), or create an immutable class by declaring all fields final and writing a constructor. But Java doesn't provide copy methods, so updating state requires creating a new builder or constructor call with all parameters, even for fields that haven't changed.

The `copy()` method is what makes immutability practical. When you need to update the state, you create a new instance with just the fields you want to change. So `state.copy(sequences = newMap)` gives you a new object where only the sequences map is different - everything else is exactly the same.

But what actually makes this efficient is how copy() works: the copy operation doesn't actually clone everything. It only allocates new memory for the changed fields, while unchanged fields just share references to the existing data. 

This sharing is safe because the data class is immutable. If you have `val sequences: Map<String, Long>`, the copied object shares a reference to the same Map instance. Since Maps in Kotlin (when you use `mapOf()`) are immutable, neither the original nor the copy can modify the Map, so sharing the reference is safe. If you need to change the Map, you provide a new Map instance in the copy call, not mutate the existing one. 

The alternative in Java is either using mutable POJOs, which requires synchronized blocks and creates lock contention when you have concurrent access, or implementing the builder pattern, which typically runs to 30 or more lines of code. Meanwhile the Kotlin data class definition is 5 lines (the class declaration plus its properties), and it gives you the constructor, equals, hashCode, toString, and copy methods automatically - no generated code needed in your source file.

Now, I should mention Java Records since they were introduced in Java 14 and standardized in Java 16. Records are Java's answer to Kotlin data classes - they provide similar immutability and automatic generation of constructor, getters, equals, hashCode, and toString. So why am I still recommending Kotlin data classes?

First, the timing: Kotlin has had data classes since 2011, Java got Records in 2020 - that's 9 years where Kotlin developers had this feature. Second, and more importantly, Java Records don't have a `copy()` method. If you want to update one field in a Record, you need to create a new instance by passing all fields to the constructor again. In Kotlin, you write `state.copy(sequences = newMap)` and only specify what changed.

Third, Java Records cannot extend other classes - they can only implement interfaces. Kotlin data classes can extend classes and implement interfaces, giving you more flexibility. Fourth, Records automatically make all fields final - you can't have any mutable fields. In Kotlin, you can mix `val` and `var` if needed, though immutability is encouraged.

Finally, Records require JVM 16+. Kotlin data classes work on JVM 6+, so if you're supporting legacy systems, data classes give you this feature without upgrading your JVM.

The key advantage of Kotlin data classes is the `copy()` method with named parameters. This makes immutable programming practical without the ceremony of builders or constructors with many parameters.

---

## Slide 14-16: Functional Programming

Let me talk about functional programming, because Kotlin has excellent support for it built right into the language - you don't need special libraries for most functional patterns.

**[Point to first code block]** Let's start with the basics. In Kotlin, functions are first-class citizens. Look at this first line: `val add: (Int, Int) -> Int = { a, b -> a + b }`. This is a function type. The `(Int, Int) -> Int` part means "a function that takes two Ints and returns an Int". The syntax is clean and built into the language - no need for Java's functional interfaces like Function, BiFunction, or Consumer.

**[Point to second example]** You can also write it more concisely: `val multiply = { a: Int, b: Int -> a * b }`. Here the types are inferred.

**[Point to calculate function]** Now look at the higher-order function below. Higher-order functions are functions that take other functions as parameters or return functions. Here we have `calculate` which takes two integers and an `operation` parameter that is itself a function: `(Int, Int) -> Int`. 

**[Point to usage line]** And here's where it gets interesting: we can pass our `add` function as a parameter: `calculate(5, 3, add)`. The key thing to notice is that `add` has the same signature as the `operation` parameter - both are `(Int, Int) -> Int`. This is type-safe at compile time.

In Java, you'd need to create a functional interface or use one of the standard ones like BiFunction, which adds ceremony.

**[Point to second code block - pause 2 seconds]** Now let's look at collection operations. Operations like filter, map, fold, groupBy - these are all built-in and work seamlessly with lambdas. 

**[Walk through the example line by line]**
- First, `.filter { it % 2 == 0 }` keeps only even numbers
- Then `.map { it * it }` squares each number  
- Finally `.fold(0) { acc, value -> acc + value }` sums them up - it starts with 0 and accumulates

The lambda-as-last-parameter syntax makes this very readable - the code reads left to right, like a pipeline. In our production code, we're processing tens of thousands of items per second with these operations, and the code is 60% shorter than equivalent Java streams.

**[Point to production example]** Here's a real-world example from our system: we filter active requests, group them by user ID, and count how many each user has. This is the kind of data processing you do constantly in production systems, and Kotlin makes it concise and readable.

Immutability is another key aspect. Kotlin encourages immutability by default. When you write `listOf()` or `mapOf()`, you get an immutable collection. If you want mutability, you explicitly use `mutableListOf()` or `mutableMapOf()`. This is the opposite of Java, where ArrayList and HashMap are mutable by default, and you need to wrap them with `Collections.unmodifiableList()` to make them immutable.

This matters in concurrent code. Immutable data structures are inherently thread-safe - no locks needed. When you're handling thousands of concurrent requests, the fact that your data is immutable by default eliminates whole classes of concurrency bugs.

---

## Slide 17-19: Operator Overloading

Operator overloading lets you define custom behavior for operators like plus, minus, times, get, set on your own types. This makes domain code more natural to read and write.

Let me show you a practical example. Say you're working with money in a financial system. You can define a Money data class and overload the plus operator so you can write `price + tax` instead of `price.add(tax)`. The operator function enforces business rules - like checking that currencies match before adding. The syntax is clean: you mark the function with the `operator` keyword.

Now look at how this compares to Java. In the slide, you can see the same operations. In Kotlin: `price * 3` and `total + Money(50, "EUR")`. In Java, without operator overloading, you have to write: `price.times(3)` and `total.plus(new Money(50, "EUR"))`. 

When you're reading domain code, the Kotlin version is immediately intuitive. If you see `baseCost * quantity + shipping`, you understand it instantly. The Java version `baseCost.times(quantity).plus(shipping)` requires mental translation - you have to parse method names instead of mathematical operators.

You can overload comparison operators, arithmetic operators, and even the array access operator. For example, if you have a Matrix class, you can overload the `get` operator so you can write `matrix[row, col]` instead of `matrix.get(row, col)`. Same with `set` for mutation.

One particularly useful operator is `invoke`, which makes objects callable as functions. This is how Kotlin's DSL builders work. You can create a builder class and overload invoke to make it callable, which enables very natural DSL syntax - like configuration builders or test fixtures.

The benefit is readability. When you're reading domain code that says `totalCost = baseCost * quantity + shipping`, that's immediately clear. The Java equivalent would be `totalCost = baseCost.times(quantity).plus(shipping)`, which breaks the mental flow.

Java doesn't support operator overloading - it's a deliberate language design choice. The argument against it is that it can be abused, but in practice, when used judiciously for domain types, it makes code significantly more readable.

---

## Slide 20-22: Feature Mapping

Let me show you a Kotlin feature that Java doesn't have yet - inline value classes. These provide type safety without any runtime overhead.

In many systems, you need to distinguish between different kinds of IDs or measurements. You might have a user ID, a request ID, and a transaction ID - they're all Longs, but they represent different things. In Java, you'd either use raw Longs (losing type safety) or create wrapper classes (adding allocation overhead).

Kotlin's value classes solve this with a compile-time wrapper. You define `@JvmInline value class RequestId(val value: Long)` and the compiler treats it as a distinct type at compile time, but at runtime it's just a Long - zero allocation, zero boxing overhead.

This is particularly valuable in high-frequency code, where you pass request IDs through multiple layers - validation, mapping, routing, persistence. With value classes, we get compile-time type safety preventing bugs like passing a user ID where a request ID is expected, but at runtime there's no wrapper object allocation.

The compiler optimizes value classes away entirely. When you pass a RequestId to a function, the JVM bytecode just passes a Long. No object allocation, no garbage collection pressure. 

Java doesn't have this feature yet. Oracle is working on Project Valhalla, maybe you have heard of it. It aims to bring value types to the JVM - essentially Java's version of inline value classes. But Valhalla has been in development since 2014, over a decade now, and still doesn't have a release date. Meanwhile, Kotlin has had this feature in production since version 1.5 in 2021.

Another useful Kotlin feature is destructuring. It's a syntax feature that lets you unpack objects. You can write `val (id, name) = user` and it unpacks the object in a single line, which is particularly useful when working with data classes or Pairs. In Java, you'd need separate statements to extract each field.

---

## Slide 23-25: Extension Functions

Extension functions let you add methods to existing classes without modifying their source code or using inheritance. This is particularly useful when you're working with classes you don't own.

In Java, you achieve the same result using static utility methods. So instead of calling a method on the object, you pass the object as a parameter to a static method in a utility class. This works functionally but reduces discoverability and breaks the natural object-oriented flow.

We use Protobuf heavily for our gRPC services, and we've created extensions like `Long.toTimestamp()` that converts Unix milliseconds to Protobuf Timestamp format. In Java you'd need a utility class, so you'd write something like `ProtobufUtil.longToTimestamp(System.currentTimeMillis())`. With the extension function, it becomes `System.currentTimeMillis().toTimestamp()`.

Beyond shorter code, when you type a Long and hit dot in your IDE, the toTimestamp extension shows up in autocomplete. You don't need to remember which utility class contains which methods. The extensions are also scoped by import, so there's no namespace pollution - meaning not having too many names visible in the global scope, making it unclear where methods come from. With extensions, you explicitly import only the functions you need, and they only appear on the types they extend.

If you need to maintain multiple API versions for backward compatibility, extension functions like `Request.toCurrentVersion()` and `Collection<Request>.toSnapshot()` let you chain conversions in a single expression. You can write something like `requests.filter { it.isActive }.map { it.toCurrentVersion() }.toSnapshot(123L)` and it reads left to right. The Java equivalent would require nested utility calls or temporary variables.

Extension functions come up frequently when teams talk about why they adopted Kotlin - it's one of those features that once you start using, you really miss when you go back to Java.

---

## Slide 26-28: Concurrency Reimagined

The `StreamingService` The code example on the slide is similar to the one I've written in hot path. Here the clients subscribe to get data updates - they receive an initial snapshot, then continuous updates as data changes, with heartbeats to keep the connection alive. This service handles thousands of concurrent subscriptions.

In Java gRPC without coroutines, you'd implement this using StreamObserver with callbacks. You'd manually manage the subscription lifecycle, track active subscriptions in a concurrent map, handle threading explicitly, and coordinate error handling across callback boundaries. The callback-based approach makes the control flow harder to follow because logic is split across multiple callback methods rather than reading sequentially.
Coroutines provide several technical advantages here. First, the code structure is sequential even though execution is asynchronous. When you write `suspend fun subscribe` that returns a `Flow<Message>`, it looks like a regular function returning a collection, but the suspend keyword and Flow type make it fully asynchronous and capable of streaming data over time.

The Flow automatically handles backpressure. 
If a client is processing data slowly, the Flow applies backpressure without you writing any additional buffering logic. 
The compiler also verifies the types flowing through the stream, so you know at compile time that you're working with Message objects.

In Java gRPC, you implement this with StreamObserver, which is callback-based. 
You manually call onNext, onError, and onCompleted. You have to track subscriptions yourself for cleanup and handle error propagation explicitly across callbacks. While you could build subscription management utilities to automate some of this, it's not provided by the framework - you're writing infrastructure code rather than business logic.

With Kotlin coroutines, errors propagate through exceptions using the standard try-catch mechanism. Completion is automatic when the Flow completes. Cancellation is automatic when the client disconnects. There's no manual subscription tracking needed - no map of subscription IDs to disposable objects.

The performance characteristics are interesting. Each coroutine uses roughly 100 bytes when suspended, compared to about 1 megabyte for a Java thread. That's a 10,000x difference in memory usage. 

Coroutines provide a more maintainable async programming model than CompletableFuture, and the performance is comparable to Java 21's Virtual Threads while working on any JVM version.

Regarding debugging: IntelliJ IDEA provides specialized coroutine debuggers that show the coroutine call stack and suspension points. For Java threads, you see the traditional call stack. For coroutines, you can inspect which coroutines are suspended and their state. The presentation slide includes a screenshot of the coroutine debugger showing this capability. However, debugging async code in general - whether coroutines or threads - is more complex than synchronous code, and this comparison deserves its own deep-dive session.
---

## Slide 29-31: The Framework Decision

Let me show you how both Spring Boot and Ktor work in Kotlin, with fair side-by-side comparisons.

First, dependency injection. The `StreamingService` constructor shows Spring Boot's approach - you define properties directly in the constructor with no separate field declarations or manual assignments. What would be 20 lines in Java becomes 7 lines in Kotlin. 

You can also provide default parameters right in the constructor, like `channelBufferSize = 1_000`. Java doesn't support default parameters at the language level, so you'd need multiple constructor overloads. All the properties are `val`, which makes them immutable - thread-safe by default. Lambda parameters like `(Message) -> Unit` work directly in Kotlin's type system without requiring functional interfaces.

Now look at the endpoint comparison. Spring Boot uses RestController with annotations - `@GetMapping("/users/{id}")` and a suspend function. This works with Spring WebFlux and coroutine adapters. It's familiar if you know Spring.

Ktor uses a routing DSL instead. In the Ktor DI example, you can see `val userService by inject<UserService>()` - this uses Koin for dependency injection. Then the routing block defines endpoints with `get("/api/users/{id}")` in a DSL style. The key difference: Ktor's endpoint handlers are just suspend function blocks - no annotations needed.

[Point to comparison table] Now let's look at the practical differences. For dependency injection, both frameworks support it, but Spring has the more powerful IoC container with profiles, AOP, and extensive auto-configuration. Ktor with Koin is simpler - just basic DI without the complexity.

For endpoints, both work with coroutines. Spring uses annotations you already know - `@GetMapping`, `@PostMapping`. Ktor uses DSL blocks - `get()`, `post()`. It's really about whether you prefer annotations or DSL syntax.

Coroutines support is where it gets interesting. Spring WebFlux added coroutine support through adaptation layers - it bridges between Reactor's `Mono`/`Flux` types and Kotlin's `suspend` functions. Ktor was built with coroutines from day one, so there's no bridging - you work directly with suspend functions throughout.

Look at startup time and memory usage. Spring Boot typically takes 5-10 seconds to start and uses 200MB+ base memory due to its extensive feature set - auto-configuration scanning, AOP proxy generation, complex DI container initialization. Ktor starts in 1-2 seconds and uses around 50MB because it's architecturally simpler with fewer abstraction layers.

The use case column tells you when to choose each. Spring Boot is your choice for enterprise applications needing the full ecosystem - Spring Data, Spring Security, message queues, all the integrations. Ktor is better for lightweight microservices that are mostly routing and async operations with coroutines.

There's one thing to be aware of with Spring and Kotlin: Kotlin classes are final by default, but Spring needs classes to be open for CGLIB proxies. The solution is the kotlin-spring compiler plugin, which automatically makes classes with Spring annotations open. You can also use the open keyword manually or switch to interface-based proxies.

At Deutsche Börse, we use Spring Boot because we need the extensive ecosystem - Spring Data, Spring Security, all of that. 
The team already knows Spring, and we value the enterprise support.

For new microservices though, it's worth evaluating Ktor. 
Ktor is designed with coroutines as a first-class concept from the ground up, whereas Spring Boot added coroutine support later. 
In Ktor, you write your handlers directly as suspend functions and return Flow types without any wrappers. 

In Spring WebFlux with coroutines, you need to use specific annotations and sometimes wrap reactive types. For those who are not familiar, Project Reactor is Spring's reactive programming library providing types like Mono and Flux for asynchronous streams. Spring WebFlux was built on Reactor before Kotlin coroutines existed. When Spring added coroutine support, they had to bridge between Reactor's reactive types and Kotlin's suspend functions and Flows. In Ktor, since it was built with coroutines from day one, there's no bridging layer - you work directly with suspend functions and Flow types.

Ktor has less framework overhead because it's architecturally simpler - it doesn't include Spring's extensive features like aspect-oriented programming, complex dependency injection container, auto-configuration system, or comprehensive security framework. This results in faster startup times (typically 1-2 seconds vs 5-10 seconds for Spring Boot) and smaller memory footprint (base memory around 50MB vs 200MB+ for Spring Boot). For a simple microservice that's mostly routing requests and calling other services, you don't need all of Spring's features, and Ktor's simpler architecture means there are fewer abstraction layers to go through.

The way I think about the choice: 
use Spring when you're building enterprise applications that need ecosystem integration - database access, security, message queues - and you have existing Spring knowledge on the team. 

Consider Ktor for focused microservices where you want a lighter framework and you're building a service that's heavily async with coroutines from top to bottom. Ktor is coroutine-native, while Spring added coroutine support later through adaptation layers.

---

## Slide 32-34: Ecosystem Recommendations

Let's compare Kotlin's ecosystem to Java's. Java's ecosystem is larger and more mature - it's been around for 25+ years. However, Kotlin has full interoperability with Java libraries, so you can use any Java library in Kotlin. What Kotlin adds is its own ecosystem of libraries specifically designed for Kotlin's features.

For testing, MockK is designed specifically for Kotlin and supports all Kotlin features like data classes and extensions. It handles Kotlin-specific features that Mockito struggles with, like suspend functions and inline classes. That said, Mockito also works in Kotlin, just not as idiomatically.

For dependency injection, Koin is a lightweight alternative to Spring. While Spring uses reflection and runtime proxy generation with a complex container that handles AOP, lifecycle management, and auto-configuration, Koin uses a simple DSL that's evaluated at compile time. Spring is more powerful and feature-rich, but Koin is easier to understand and has near-zero overhead - definitions are just functions that instantiate objects. For microservices that don't need Spring's full feature set, Koin provides basic DI without the complexity.

Other tools worth knowing about: Exposed for type-safe SQL, kotlinx.serialization for compile-time JSON handling, and the Coroutines library itself for reactive streams with Flow. For advanced functional programming patterns beyond Kotlin's built-in capabilities, Arrow provides types like Either, Option, and effect handling.

The ecosystem is mature and production-ready. You're not pioneering uncharted territory here.

---

## Slide 35: Learning Resources

If you're interested in learning Kotlin, let me share some resources that I found helpful and that teams at my company have used successfully.

First, Kotlin Koans. This is an interactive tutorial that runs right in your IDE - either IntelliJ IDEA or as a web version. It has 42 exercises that walk you through Kotlin syntax and idioms step by step. Each exercise is small and focused - you write a few lines of code to make a test pass. Topics include collections, properties, conventions, generics, and more. This is hands-on learning - you're not just reading, you're actually writing Kotlin code from day one.

The official documentation at kotlinlang.org is excellent. It's well-organized and includes lots of examples. The Kotlin Style Guide is particularly useful for learning idiomatic patterns - how experienced Kotlin developers write code.

For books, "Kotlin in Action" by Dmitry Jemerov and Svetlana Isakova is the definitive guide. Both authors work at JetBrains on the Kotlin team. "Effective Kotlin" by Marcin Moskała is more advanced - it's similar to "Effective Java" but for Kotlin, covering best practices and common pitfalls.

JetBrains Academy offers interactive courses where you learn by building projects. It's structured learning with automatic feedback.

The Kotlin community is active and helpful. The Kotlin Slack has over 50,000 members and channels for different topics - coroutines, Android, backend, multiplatform. KotlinConf talks are all on YouTube and cover everything from beginner topics to advanced language features. The /r/Kotlin subreddit is also quite active for questions and discussions.

My recommendation: start with Kotlin Koans to get a feel for the syntax, then pick a small project or feature in your codebase to convert to Kotlin. The best way to learn is by doing.

---

## Slide 36: Key Takeaways

There are many Kotlin features we haven't covered - inline classes, contracts, context receivers, delegation, type aliases, sealed classes, DSL builders, and more. The goal of this talk was to focus on the features that provide the most immediate practical value when transitioning from Java, particularly around null safety, data modeling, functional programming, operator overloading, extension functions, async programming, and framework integration. Think of this as your foundation - the 20% of Kotlin features that you'll use 80% of the time.

Let me summarize the key points. Null safety at the type level eliminates NullPointerExceptions - we've seen zero NPEs from Kotlin code in production while our legacy Java services still see them monthly.

We're seeing 40 to 50 percent less code overall. Data classes give us 83% reduction, dependency injection configuration is 65% less code, and null handling is 43% less compared to Java.

Extension functions improve how you organize code with better discoverability and natural method chaining. Operator overloading makes domain code more natural and readable. First-class functions eliminate the need for functional interfaces. Coroutines and Flow provide a simpler async programming model - about 50% less code than Java and more maintainable than CompletableFuture, with performance comparable to Java 21's Virtual Threads.

Inline value classes provide type safety without runtime overhead - a feature Java has been trying to deliver via Project Valhalla for over a decade. We've proven this at production scale handling more than 30 million requests per day with over 10,000 concurrent gRPC streams.

Spring Boot integration is mature with first-class support - just remember to use the kotlin-spring compiler plugin to handle the final class issue.

The learning curve is typically 2 to 4 weeks, and teams generally report productivity improvements after that initial ramp-up.

Looking at our specific metrics: we saved about 20,000 lines of code, which is a measured 40% reduction across the codebase. We can handle 10,000 concurrent subscriptions on 4 CPU cores, which would be about 400 max with thread-per-connection in Java. Memory efficiency is under 1 gigabyte for our subscriptions versus the roughly 10 gigabytes that would be required for an equivalent thread-based Java implementation. We estimate we saved 6 to 9 months of development time compared to a full Java rewrite.

The bottom line is that Kotlin provides measurable improvements in code quality, reduces maintenance burden, and increases system reliability. The production case study I've shown you demonstrates that this works at scale under demanding requirements.

Regarding the learning investment: that 2 to 4 week learning curve results in 40% less code to maintain long-term, and teams typically see productivity gains after the initial ramp-up period.

---

## Slide 37: Questions?

I'm happy to dive deeper into any of these topics, discuss specific tradeoffs you might be considering, or talk about how Ktor versus Spring Boot might work for your particular deployment needs. Thanks for your time.
