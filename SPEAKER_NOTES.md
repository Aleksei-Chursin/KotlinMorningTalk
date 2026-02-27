# Speaker Notes - Kotlin for Java Developers

## Slide 1: Welcome

Good morning! I'm Aleksei. Today we're going straight to practical Kotlin - not "why Kotlin" philosophy, but tangible features that help you write better code faster.

This talk is targeted at Java developers who have 2-3 years of experience and either want to adopt Kotlin in their team or understand what the buzz is about.

We're going to cover 9 topics in roughly an hour. Each one is a skill you can pick up and use immediately in your projects. Let's dive in.

---

## Slide 2: About Me

Aleksei. 5+ years in Java, including 2 years junior-leading. Currently at Deutsche Börse working on the intraday power trading system - we handle 30+ million requests per day.

I'm a reactive programming enthusiast. Kotlin Flows, coroutines, WebFlux - these aren't just buzzwords for me, they're production reality at scale.

You'll see in this talk: real patterns, real tradeoffs, real-world decisions. Nothing academic.

---

## Slide 3: Today's Plan

We're covering 9 topics. First three are about syntax: dropping the Java ceremony, null safety, and powerful data handling. Topics 4-6 are about features that make code cleaner. Topics 7-9 are about deployment: concurrency, frameworks, and what tools matter.

We'll keep it practical. I show a problem + Kotlin solution + sometimes Java comparison. That way you see the value.

---

## Slide 4-6: The "Unlearning" Phase

Java taught us some habits we need to forget in Kotlin:

**Semicolons?** Optional. Don't write them.

**The new keyword?** Gone. Just call the constructor directly.

**Static methods everywhere?** No need. Top-level functions are simpler.

These aren't features - they're missing boilerplate. But clean code matters. Especially when your codebase has thousands of files. Every line you remove is a line you don't have to read, test, or maintain.

Example at scale: Deutsche Börse. We have high-performance requirements. Every microsecond matters. Kotlin's top-level functions (no class wrapping) + inline functions actually help with performance profiles. But more importantly, the code is clearer.

---

## Slide 7-10: Null Safety - The Real Power

Java's Optional is a band-aid. Kotlin's null-safety is architectural.

In Kotlin, `String` and `String?` are different types. Not an opinion - the compiler enforces it.

Why? Because most Java bugs in production are null-related. You skip a null check. System crashes. Kotlin makes that impossible.

Safe calls (`?.`), Elvis operator (`?:`), and null coalescing - these are your tools.

Show example: If I have `user?.let { ... }` - I'm saying "IF user is not null, do this". And the code reads naturally.

---

## Slide 11-13: Data Classes & Properties

Data classes aren't just syntactic sugar. They change how you think about data.

One line gives you: constructor, equals, hashCode, toString, copy.

Copy is important because immutability is the default. `val user1.copy(name = "Bob")` creates a new object. No mutations. Predictable behavior.

Properties with getters/setters? Kotlin lets you add validation. Private backing field, public property with validation logic. Java requires 15 lines of code. Kotlin: 5 lines.

---

## Slide 14-16: Smart Casting

The compiler knows types. Use that knowledge.

After you check `if (obj is String)`, inside that block, the compiler knows obj IS a String. No need to cast. You just use it.

`when` expressions + type checking are powerful for pattern matching. Not full pattern matching like Scala, but enough to make code cleaner.

Safe cast with `as?` returns null if incompatible. Never throws.

---

## Slide 17-19: Feature Mapping

Java: Stream API. Map, filter, collect. Eager evaluation - builds intermediate lists.

Kotlin: Sequences. Same patterns. Lazy evaluation - only computed when needed.

For small lists, doesn't matter. For large datasets or pipelines, Sequences are more efficient.

Destructuring is a bonus: `val (id, name) = user` unpacks in one line. Readable.

---

## Slide 20-23: Functional Idioms

Japan's scope functions: `let`, `apply`, `run`, `also` - they are context receivers that make code cleaner.

`let`: Transform something and use the result. Often with null: `name?.let { it.uppercase() }`

`apply`: Configure an object and return it. Good for builders.

`run`: Execute logic in context. Less common.

`also`: Side effect then return. Debugging helper.

These aren't necessary. You can write Kotlin without them. But they make code read better once you learn them.

---

## Slide 24-26: Concurrency Reimagined

Threads are heavy. Callbacks are complex. Coroutines solve both.

Coroutines suspend, not block. Your function looks sync but suspends when waiting. Meanwhile, the thread serves other coroutines.

Structured concurrency: Tasks are logically grouped. If one fails, siblings cancel. Automatic cleanup. No resource leaks.

Project Loom (Java's virtual threads) is moving Java in this direction. But Kotlin got there 5 years earlier.

---

## Slide 27-29: The Framework Decision

**Spring Boot**: 100 years of Java ecosystem, mature, handles everything, sometimes bloated, perfect for enterprise complexity.

**Ktor**: Lightweight, coroutines-first, beautiful API, smaller ecosystem, perfect for microservices and performance-critical code.

At Deutsche Börse, we use Spring Boot. Ecosystem matters at scale. But for a new microservice? I'd pick Ktor today.

---

## Slide 30-32: Ecosystem Recommendations

**MockK**: Mocking for Kotlin. Supports all Kotlin features (data classes, extensions, etc). Better than Mockito for Kotlin.

**Koin**: Lightweight DI. No reflection magic. Compile-time safe. Simple to use.

**Arrow**: Functional programming library. Either, Option, effects. If you want Scala-like FP in Kotlin, Arrow is it.

Also know about: Exposed (SQL DSL), Kotlinx.serialization (compile-time JSON), Coroutines itself.

The ecosystem is mature. Production-ready. You're not pioneering.

---

## Slide 33: Key Takeaways

1. Unlearning Java ceremony helps.
2. Null safety prevents entire categories of bugs.
3. Data classes eliminate generator boilerplate.
4. Smart casting cleans up type checking.
5. Functional idioms improve readability.
6. Coroutines make concurrency bearable.
7. Framework choice matters at scale.
8. Ecosystem is proven and solid.

---

## Slide 34: Questions?

Open discussion. I'm happy to dig into any topic, discuss trade-offs, or debate the relative merits of Ktor vs Spring Boot relative to your specific deployment constraints.

Thank you.
