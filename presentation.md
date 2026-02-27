% Kotlin for Java Developers
% Aleksei Chursin
% February 2026

# Welcome

**Kotlin for Java Developers**

*From scaling systems to shipping faster*

---

# About Me

- Java developer, 5+ years commercial experience
- Currently working at: @Deutsche Börse (intraday power trading, +30M requests/day)
- Love reactive programming: Kotlin Flows, Coroutines, WebFlux
- 2 years junior-leading experience
- Passionate about teaching and mentoring

---

# Today's Plan

1. The "Unlearning" Phase
2. Null Safety in Action
3. Data Classes & Properties
4. Smart Casting
5. Feature Mapping
6. Functional Idioms
7. Concurrency Reimagined
8. The Framework Decision
9. Ecosystem Recommendations

---

# 1. The "Unlearning" Phase

## Semicolons: Actually Optional

```kotlin
val x = 42
val y = "hello"
val z = listOf(1, 2, 3)  // No semicolon needed
```

## The `new` Keyword Is Gone

```java
// Java
Person p = new Person("Alice", 30);
```

```kotlin
// Kotlin - no "new"
val p = Person("Alice", 30)
```

## No Static Overhead

```kotlin
// Top-level functions (no class needed)
fun calculateTotal(items: List<Int>): Int {
    return items.sum()
}

// Use it anywhere
val result = calculateTotal(listOf(1, 2, 3))
```

---

# 2. Null Safety in Action

## Safe Calls: `?.` Operator

```kotlin
val name: String? = getName()
println(name?.length)  // null if name is null, otherwise prints length
```

## Elvis Operator: `?:`

```kotlin
val displayName = name ?: "Guest"  // Use "Guest" if name is null
```

## Non-Null Assertion: `!!`

```kotlin
val length = name!!.length  // Throws if null (use sparingly)
```

## Scope Functions with Null Checks

```kotlin
user?.let {
    println("User: ${it.name}")
    sendWelcomeEmail(it)
}
```

---

# 3. Data Classes & Properties

## One-Line Data Classes

```kotlin
data class User(val id: Int, val name: String, val email: String)
```

Automatically generates:
- Constructor
- `equals()` & `hashCode()`
- `toString()`
- `copy()` function

## Properties with Backing Fields

```kotlin
class Account {
    private var _balance: Double = 0.0
    
    var balance: Double
        get() = _balance
        set(value) {
            if (value >= 0) _balance = value
        }
}
```

## Copy Constructor

```kotlin
val user1 = User(1, "Alice", "alice@example.com")
val user2 = user1.copy(name = "Bob")  // Only name changes
```

---

# 4. Smart Casting

## Automatic Type Narrowing

```kotlin
val obj: Any = "Hello"

if (obj is String) {
    println(obj.length)  // obj automatically cast to String!
}
```

## Safe Cast: `as?`

```kotlin
val str = obj as? String  // Returns null if not String
println(str?.uppercase())
```

## When with Type Checks

```kotlin
when (obj) {
    is String -> println("It's a string: $obj")
    is Int -> println("It's an int: $obj")
    else -> println("Something else")
}
```

---

# 5. Feature Mapping

## Stream → Sequences (Lazy Evaluation)

```kotlin
// Java: eager evaluation
list.stream()
    .filter(x -> x > 5)
    .map(x -> x * 2)
    .collect(Collectors.toList())

// Kotlin: lazy evaluation
list.asSequence()
    .filter { it > 5 }
    .map { it * 2 }
    .toList()
```

## Collections API

```kotlin
val numbers = listOf(1, 2, 3, 4, 5)

numbers.filter { it > 2 }
    .map { it * 2 }
    .forEach { println(it) }
```

## Destructuring

```kotlin
val pair = Pair(1, "one")
val (num, str) = pair

// With data classes
val (id, name) = User(1, "Alice", "alice@test.com")
```

---

# 6. Functional Idioms

## `let`: Transform and Use

```kotlin
val result = name?.let {
    it.uppercase()
}.orEmpty()
```

## `apply`: Configure and Return

```kotlin
val user = User(1, "", "").apply {
    name = "Alice"
    email = "alice@example.com"
}
```

## `run`: Execute and Return

```kotlin
val length = "hello".run {
    this.length
}
```

## `also`: Side Effects

```kotlin
val x = listOf(1, 2, 3)
    .also { println("List: $it") }
    .filter { it > 1 }
```

---

# 7. Concurrency Reimagined

## Coroutines: Async Without Threads

```kotlin
launch {
    val user = fetchUser(userId)  // Suspends, no blocking
    val posts = fetchPosts(userId)
    displayUser(user, posts)
}
```

## Structured Concurrency

```kotlin
coroutineScope {
    val user = async { fetchUser(id) }
    val posts = async { fetchPosts(id) }
    
    combine(user.await(), posts.await())
}
```

## Project Loom Bridge

```kotlin
// Virtual threads (future Java)
// Kotlin coroutines now similar to Java's direction
suspend fun operation() {
    delay(1000)  // Non-blocking
}
```

---

# 8. The Framework Decision

## Spring Boot: Full-Featured

```kotlin
@SpringBootApplication
@RestController
class Application {
    @GetMapping("/users/{id}")
    suspend fun getUser(@PathVariable id: Int) = userService.findById(id)
}
```

## Ktor: Lightweight & Functional

```kotlin
embeddedServer(Netty, 8080) {
    routing {
        get("/users/{id}") {
            val id = call.parameters["id"]?.toInt() ?: return@get
            call.respond(userService.findById(id))
        }
    }
}.start(wait = true)
```

**When to choose:**
- **Spring Boot**: Enterprise, existing ecosystem, complexity
- **Ktor**: Microservices, coroutines-first, lightweight

---

# 9. Ecosystem Recommendations

## Testing: MockK

```kotlin
val userService = mockk<UserService>()
every { userService.findById(1) } returns User(1, "Alice", "alice@test.com")

verify { userService.findById(1) }
```

## DI: Koin

```kotlin
val koinModule = module {
    single { UserRepository() }
    factory { UserService(get()) }
}
```

## Functional Programming: Arrow

```kotlin
val result = Either.Right(42)
    .map { it * 2 }
    .flatMap { value -> Either.Right(value + 1) }
```

## Other Essentials

- **Exposed**: Type-safe SQL DSL
- **Kotlinx.serialization**: JSON at compile-time
- **Coroutines**: Flow for reactive streams

---

# Key Takeaways

1. **Unlearning Java patterns** makes you faster
2. **Null safety** built-in, not optional
3. **Data classes** eliminate boilerplate
4. **Compiler does the work** with smart casting
5. **Functional idioms** clean up business logic
6. **Coroutines scale better** than threads
7. **Framework choice depends on goals**
8. **Ecosystem is mature** and battle-tested

---

# Questions?

*Let's discuss. What resonates with your current challenges?*
