% Kotlin for Java Developers
% Aleksei Chursin
% March 2026

# Welcome

**Kotlin for Java Developers**

---

# About Me

- Java developer, 6+ years commercial experience
- Currently working at: @Deutsche Börse (intraday power trading, +30M requests/day)
- Love reactive programming: Kotlin Flows, Coroutines, WebFlux
- 2 years junior-leading experience
- Passionate about teaching and mentoring

---

# Today's Plan

**Block 1: Syntax & Safety**  
_(Getting rid of Java ceremony)_

1. The "Unlearning" Phase
2. Null Safety in Action
3. Data Classes & Properties

**Block 2: Functional & Expressive**  
_(Language features that make code cleaner)_

4. Functional Programming
5. Operator Overloading
6. Feature Mapping
7. Extension Functions

**Block 3: Practical**  
_(Real-world usage)_

8. Concurrency Reimagined
9. The Framework Decision
10. Ecosystem Recommendations
11. Learning Resources

---

# 1. The "Unlearning" Phase

## Semicolons: Actually Optional

```kotlin
val x = 42
val y = "hello"
val z = listOf(1, 2, 3)  // No semicolon needed
```

## val vs var: Immutability First

```kotlin
val name = "Alice"  // Immutable - like 'final' in Java
// name = "Bob"     // ERROR: Compile error

var age = 25        // Mutable - can be reassigned
age = 26            // OK

val items = mutableListOf(1, 2, 3)
items.add(4)        // OK: Reference is immutable, content can change
```

**Default to `val`** - only use `var` when you need mutability

## The `new` Keyword Is Gone

```java
// Java
Person p = new Person("Alice", 30);
```

```kotlin
// Kotlin - no "new"
val p = Person("Alice", 30)
```

---

# 1. Top-Level & Inline Functions

## No Static Overhead

```kotlin
// Top-level functions (no class needed)
fun calculateTotal(items: List<Int>): Int {
    return items.sum()
}

// Use it anywhere
val result = calculateTotal(listOf(1, 2, 3))
```

## Inline Functions: Zero-Cost Abstractions

```kotlin
inline fun List<Int>.filterAndSum(predicate: (Int) -> Boolean): Int {
    var sum = 0
    for (item in this) {
        if (predicate(item)) sum += item
    }
    return sum
}

// Lambda is inlined - no allocation, no Function object
val result = list.filterAndSum { it > 5 }
```


---

# 2. Null Safety in Action

## The Type System

```kotlin
// In Kotlin, nullable and non-null are different types
val name: String = "Alice"     // Cannot be null
val maybeName: String? = null   // Can be null

// Compiler error - type mismatch
// val x: String = maybeName
```

## Production Example: Safe Early Returns

```kotlin
@Component
class StreamingService {
    fun send(broadcasts: Iterable<Broadcast>) {
        val ctx = context ?: return  // Elvis: return if null
        
        // ctx is now smart-cast to non-null type
        ctx.scope.launch {
            val messages = broadcasts.asSequence()
                .filterIsInstance<MessageBroadcast>()
                .map { it.data.build() }
                .toList()
            
            ctx.channel.send(messages)  // Safe - no null check
        }
    }
}
```

---

# 2. Safe Calls & Elvis Operator

## Safe Calls with `let`

```kotlin
// Building objects with optional fields
fun buildRequest(
    request: Request,
    modification: RequestModification
) {
    // "it" is the non-null value of clientId
    modification.clientId?.let { clientId ->
        builder.clientId = clientId
    }
    modification.priceDelta?.let { delta ->
        builder.priceDelta = delta.value
    }
}
```

## Elvis Operator for Defaults

```kotlin
builder.price = (modification.price
    ?: request.price).value

builder.quantity = modification.quantity
    ?: request.quantity
```

---

# 3. Data Classes & Properties

## Production Domain Models

```kotlin
// Thread-safe by default (immutability)
data class ServiceState<T>(
    val internal: T,
    val sequences: Map<String, Long>
)

data class Health(
    val status: Status,
    val details: Map<String, String>
)
```

**Auto-generated**: `equals()`, `hashCode()`, `toString()`, `copy()`

**vs Java pre-Records**: 50+ lines needed

---

# 3. Immutable Updates

## Immutable Updates with Copy

```kotlin
val state = ServiceState(
    internal = ServiceStatus.RUNNING,
    sequences = mapOf(
        "request" to 123L,
        "response" to 456L
    )
)

// Immutable update - only sequences change
val updated = state.copy(
    sequences = mapOf(
        "request" to 124L,
        "response" to 456L
    )
)
```

---

# 3. Kotlin Data Classes vs Java Records

**Java Records** (Java 14+, standardized in 16):
```java
record Point(int x, int y) {}  // Immutable, generates: constructor, getters, equals, hashCode, toString
```

**Key Differences:**

| Feature | Kotlin Data Classes (2011) | Java Records (2020) |
|---------|---------------------------|---------------------|
| `copy()` method | YES: Built-in with named parameters | NO: No copy method |
| Inheritance | YES: Can extend classes | NO: Cannot extend classes |
| Custom body | YES: Full class features | LIMITED: Only compact constructor |
| Mutability | YES: Can mix `val`/`var` | NO: All fields final |
| JVM version | YES: Works on JVM 6+ | LIMITED: Requires JVM 16+ |

**Kotlin advantage:** `copy()` makes immutable updates practical

---

# 4. Functional Programming

## First-Class Functions

```kotlin
// Functions are values - no interfaces needed
val add: (Int, Int) -> Int = { a, b -> a + b }
val multiply = { a: Int, b: Int -> a * b }

// Higher-order functions
fun calculate(
    x: Int,
    y: Int,
    operation: (Int, Int) -> Int
): Int {
    return operation(x, y)
}

val result = calculate(5, 3, add)  // 8
```

**Java**: Requires functional interfaces OR custom declarations

---

# 4. Collection Operations

## Collection Operations

```kotlin
val numbers = listOf(1, 2, 3, 4, 5)

val result = numbers
    .filter { it % 2 == 0 }
    .map { it * it }
    .fold(0) { acc, value -> acc + value }  // 20

// Production: 10K+ items/second
val activeRequests = requests
    .filter { it.status == Status.ACTIVE }
    .groupBy { it.userId }
    .mapValues { (_, reqs) -> reqs.size }
```

**Benefit**: 60% less code vs Java streams

## Immutability by Default

```kotlin
val data = listOf(1, 2, 3)  // Immutable
val map = mapOf("a" to 1)   // Immutable

// Mutable explicitly marked
val mutableData = mutableListOf(1, 2, 3)
```

**vs Java**: Collections are mutable by default, immutability requires `Collections.unmodifiable*()` wrappers

---

# 5. Operator Overloading

## Custom Operators for Domain Types

```kotlin
// Money type with custom arithmetic
data class Money(val amount: Long, val currency: String) {
    operator fun plus(other: Money): Money {
        require(currency == other.currency) { "Currency mismatch" }
        return Money(amount + other.amount, currency)
    }
    
    operator fun times(multiplier: Int): Money =
        Money(amount * multiplier, currency)
}

// Natural arithmetic syntax
val price = Money(100, "EUR")
val total = price * 3  // Money(300, "EUR")
val sum = total + Money(50, "EUR")  // Money(350, "EUR")
```

**Java equivalent (without operator overloading):**
```java
Money price = new Money(100, "EUR");
Money total = price.times(3);  // Money(300, "EUR")
Money sum = total.plus(new Money(50, "EUR"));  // Money(350, "EUR")
```

**Compare readability:**
- Kotlin: `baseCost * quantity + shipping`
- Java: `baseCost.times(quantity).plus(shipping)`

## Collection Access

```kotlin
// Custom get/set operators
class Matrix(private val data: Array<IntArray>) {
    operator fun get(row: Int, col: Int) = data[row][col]
    operator fun set(row: Int, col: Int, value: Int) {
        data[row][col] = value
    }
}

val matrix = Matrix(arrayOf(intArrayOf(1, 2), intArrayOf(3, 4)))
val value = matrix[0, 1]  // 2
matrix[1, 0] = 5
```

## Invoke Operator

```kotlin
// Make objects callable as functions
class RequestBuilder {
    private val params = mutableMapOf<String, String>()
    
    operator fun invoke(key: String, value: String) = apply {
        params[key] = value
    }
    
    fun build() = params.toMap()
}

// DSL-like syntax
val request = RequestBuilder()
    ("userId", "123")
    ("action", "submit")
    .build()
```

**Java alternative**: Method chaining only (`.add()`, `.set()`), less natural syntax

---

# 6. Feature Mapping

## Inline Value Classes: Type Safety Without Runtime Cost

```kotlin
// Compile-time wrapper, runtime just a Long - zero allocation
@JvmInline
value class RequestId(val value: Long)

@JvmInline
value class UserId(val value: Long)

// Type-safe at compile time
fun processRequest(requestId: RequestId, userId: UserId) {
    // Cannot accidentally swap parameters
}

// Usage
val requestId = RequestId(12345L)
processRequest(requestId, userId)  // Type-checked
processRequest(userId, requestId)  // Compile error!
```


## Destructuring

```kotlin
val pair = Pair(1, "one")
val (num, str) = pair

// With data classes - extract multiple fields
val (id, name, email) = User(1, "Alice", "alice@test.com")

// Ignore fields with underscore
val (id, _, email) = user
```

---

# 7. Extension Functions

## Adding Methods to Existing Types

```kotlin
// Production code - extending protobuf types
fun Long.toTimestamp() = Timestamp.newBuilder().also {
    it.seconds = Math.floorDiv(this, 1000)
    it.nanos = Math.floorMod(this, 1000) * 1000000
}.build()

// Usage
val timestamp = System.currentTimeMillis().toTimestamp()
```

## Domain Extensions for API Versioning

```kotlin
fun Request.toCurrentVersion(securityContext: SecurityContext? = null) = 
    com.example.api.Request.newBuilder().also {
        // Mapping logic
    }

fun Collection<Request>.toSnapshot(sequenceNumber: Long) = 
    Message.newBuilder()
        .setDefaultHeader(sequenceNumber)
        .also { /* ... */ }

// Method chaining
val result = requests
    .filter { it.isActive }
    .map { it.toCurrentVersion() }
    .toSnapshot(123L)
```

**Compared to Java Utility Classes**: Better IDE autocomplete, natural method chaining, improved discoverability

---

# 8. Concurrency Reimagined

## Production gRPC Streaming with Coroutines

```kotlin
// Handles 10,000+ concurrent streams on 4 CPU cores
// Coroutines: ~100 bytes each vs 1MB per thread (10,000x less memory)
@Component
class StreamingService : StreamingServiceGrpcKt.StreamingServiceCoroutineImplBase() {
    
    override suspend fun subscribe(request: Subscription): Flow<Message> {
        state.checkStarted()
        
        return sharedFlow
            .onSubscription {
                log.info("New subscription from {}", request.clientId)
                requestSnapshotAction()
            }
            .transform { event ->
                when (event) {
                    is MessageEvent -> emit(event.payload)
                    is HeartbeatEvent -> emit(event.heartbeat)
                    is SnapshotEvent -> emit(event.snapshot)
                }
            }
    }
}
```

## Measured Benefits

**Memory efficiency**: ~100 bytes per coroutine vs ~1MB per Java thread  
**Concurrency**: 10,000+ streams on 4 cores vs ~1,000 threads maximum  
**Code reduction**: 50% less code (no StreamObserver callbacks)  
**Backpressure**: Automatic flow control vs manual buffering logic

## Debugging Coroutines

![Coroutine Debugger](images/coroutineDebugger.png)

IntelliJ IDEA shows coroutine suspension points and state - essential for debugging async code

---

# 9. The Framework Decision: Spring Boot

## Spring Boot: Production DI Example

```kotlin
// Constructor injection: 7 lines vs 20 in Java (65% reduction)
// Immutability enforced by 'val' - thread-safe by default
@Component
class StreamingService(
    @Value("\${streaming.channel.buffer.size}")
    private val channelBufferSize: Int = 1_000,
    private val dispatchers: Dispatchers,
    @Autowired(required = false)
    private val droppedMessageHandler: (Message) -> Unit = {},
    @Autowired @Lazy
    private val eventPublisher: EventPublisher
)
```

**Kotlin advantages**: Automatic property creation, default values, enforced immutability

## Spring Boot: Endpoint Example

```kotlin
@RestController
@RequestMapping("/api")
class UserController(private val userService: UserService) {
    
    @GetMapping("/users/{id}")
    suspend fun getUser(@PathVariable id: Int): User {
        return userService.findById(id)
    }
}
```

**Note**: Requires Spring WebFlux for suspend functions. Works with coroutines through adapters.

---

# 9. The Framework Decision: Ktor

## Ktor: DI Example

```kotlin
fun Application.module() {
    val userService by inject<UserService>()  // Koin DI
    
    routing {
        get("/api/users/{id}") {
            val id = call.parameters["id"]?.toInt() ?: return@get
            call.respond(userService.findById(id))
        }
    }
}
```

**Direct coroutine support**: `suspend` functions work naturally without adapters

## Framework Comparison

| Aspect | Spring Boot | Ktor |
|--------|-------------|------|
| **DI** | Constructor injection, annotations | Koin or manual |
| **Endpoints** | Controllers with annotations | DSL routing blocks |
| **Coroutines** | Adapter layer (added later) | Native from day one |
| **Startup** | 5-10 seconds | 1-2 seconds |
| **Memory** | 200MB+ base | 50MB base |
| **Best for** | Enterprise apps, large teams | Microservices, async-heavy |

**When to choose**: Spring (enterprise, ecosystem), Ktor (lightweight microservices, coroutines-first)

---

# 10. Ecosystem Recommendations

## Testing: MockK

```kotlin
val userService = mockk<UserService>()
every { userService.findById(1) } returns User(1, "Alice", "alice@test.com")

verify { userService.findById(1) }
```

## DI: Koin (Lightweight Alternative to Spring)

```kotlin
val koinModule = module {
    single { UserRepository() }
    factory { UserService(get()) }
}
```

**Koin vs Spring**: Koin is simpler (no reflection, no AOP), near-zero overhead. Spring is more powerful for enterprise applications needing full ecosystem.

## Other Essentials

- **Exposed**: Type-safe SQL DSL
- **Kotlinx.serialization**: JSON at compile-time
- **Coroutines**: Flow for reactive streams
- **Arrow**: Advanced functional programming (Either, Option, effect handling) - optional for FP-heavy projects

---

# Learning Resources

## Kotlin Koans

Interactive exercises in your IDE - learn by solving 42 tasks covering Kotlin syntax and idioms

**Best for**: Hands-on learners who want to practice immediately

## Official Documentation

- **kotlinlang.org** - Comprehensive language guide
- **Kotlin Style Guide** - Idiomatic Kotlin patterns
- **Kotlin Blog** - Updates and best practices from JetBrains

## Books & Courses

- **Kotlin in Action** (Dmitry Jemerov, Svetlana Isakova)
- **Effective Kotlin** (Marcin Moskała)
- **JetBrains Academy** - Interactive courses

## Community

- Kotlin Slack (50,000+ members)
- KotlinConf talks on YouTube
- /r/Kotlin subreddit

---

# Key Takeaways

1. **Null safety prevents production bugs** - Type-level enforcement
2. **40-50% less code** - Data classes, extensions, functional APIs
3. **First-class functions eliminate ceremony** - No functional interfaces needed  
4. **Extension functions improve code organization** - Natural method chaining
5. **Operator overloading for domain clarity** - Natural arithmetic and access syntax
6. **Inline value classes = type safety + zero overhead** - Java waiting on Valhalla since 2014
7. **Coroutines + Flow provide simpler async** - Better than CompletableFuture
8. **Production-proven** - 30M+ req/day at scale
9. **Spring Boot integration is mature** - 65% less DI boilerplate
10. **Learning curve: 2-4 weeks** - Long-term productivity benefits

---

# Questions?

*Let's discuss. What resonates with your current challenges?*
