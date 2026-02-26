% Kotlin for Java Developers
% Aleksei Chursin
% February 2026

# Welcome

**Kotlin for Java Developers**

*A friendly introduction to modern language features*

---

# About Me

- Java developer for 10+ years
- Kotlin enthusiast
- Love making code simpler and safer

---

# Today's Plan

1. **Val and Var** - Immutability matters
2. **Null Safety** - No more NullPointerException
3. **Extension Functions** - Superpower
4. **Data Classes** - Less boilerplate
5. **Coroutines** - Simpler concurrency

---

# 1. Why Kotlin?

**The Problem:** Java is verbose. You write lots of code for simple things.

**The Story:** You start a new project. First day. You write 50 lines of code for a simple data object. You add getters, setters, equals, hashCode, toString. 

"There must be a better way," you think.

---

# 2. Val and Var

## Val (immutable)
```kotlin
val name = "Anna"
// name = "Bob"  // ERROR! Cannot change
```

## Var (mutable)
```kotlin
var count = 0
count = 1  // OK
```

---

# 3. Null Safety

## The Problem
```java
// Java
String name = getName();
System.out.println(name.length());  // What if null?
```

## Kotlin Solution
```kotlin
// Kotlin - compiler stops you
val name: String = getName()  // name CANNOT be null
val nickname: String? = getName()  // nickname CAN be null
```

---

# 4. Extension Functions

## Add methods to existing classes

```kotlin
// Add to String class without inheriting
fun String.isValidEmail(): Boolean {
    return this.contains("@")
}

// Use it
val email = "alice@example.com"
email.isValidEmail()  // true
```

---

# 5. Data Classes

## Kotlin Way

```kotlin
data class Person(val name: String, val age: Int)
```

**One line.** Equals, hashCode, toString, copy - all automatic.

---

# 6. Coroutines

## Kotlin Coroutine (clean)
```kotlin
suspend fun fetchUser(): User {
    return api.getUser()  // Async but reads sync
}

launch {
    val user = fetchUser()  // Waits here, thread free
    println(user)
}
```

---

# Real-World Example

## API Call & Display

```kotlin
data class User(val id: Int, val name: String)

suspend fun fetchUser(userId: Int): User {
    return api.getUser(userId)
}

fun showUser(userId: Int) {
    launch(Dispatchers.Main) {
        try {
            val user = fetchUser(userId)
            display.show(user.name)
        } catch (e: IOException) {
            display.showError("Network failed")
        }
    }
}
```

---

# Key Takeaways

1. **Immutability first** - `val` by default
2. **Null safety** - compiler helps you avoid crashes
3. **Less boilerplate** - data classes save keystrokes
4. **Readable async** - coroutines > callbacks
5. **Interop with Java** - you can use both

---

# Questions?

*Let us discuss. What interests you most?*
