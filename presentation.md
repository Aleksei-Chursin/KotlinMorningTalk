% Kotlin for Java Developers
% Aleksei Chursin
% February 2026

# Welcome

**Kotlin for Java Developers**

*A friendly introduction to modern language features*

---

## Speaker Notes - Slide 1

Good morning everyone! Welcome. I am excited to share Kotlin with you today. This is a practical introduction designed for Java developers like us.

Take the next few minutes to settle in. Grab a coffee, say hello to your neighbor. We will begin in 3 minutes. No rush.

---

# About Me

- Java developer for 10+ years
- Kotlin enthusiast
- Love making code simpler and safer

---

## Speaker Notes - Slide 2

A quick introduction: I have been writing Java code for a long time. Over the years, I noticed Kotlin solved many problems that frustrated me. Today I want to share what I learned. I am not here to say Java is bad. Java is solid. But Kotlin makes certain things easier, safer, and faster to write.

---

# Today's Plan

1. **Why Kotlin?** - The motivation
2. **Val and Var** - Immutability matters
3. **Null Safety** - No more NullPointerException
4. **Extension Functions** - Superpower
5. **Data Classes** - Less boilerplate
6. **Coroutines** - Simpler concurrency

---

## Speaker Notes - Slide 3

Here is our roadmap for today. Each topic follows the same pattern:

First, I tell you a story. A real problem. Then I explain why Kotlin's feature helps. And finally, I show you how to solve it without the feature. This way, you understand the value.

At the end, we look at a complex example where Kotlin really shines. Then we practice together. Tim and Jakub will help if you have questions.

Let's begin!

---

# 1. Why Kotlin?

**The Problem:** Java is verbose. You write lots of code for simple things.

**The Story:** You start a new project. First day. You write 50 lines of code for a simple data object. You add getters, setters, equals, hashCode, toString. 

"There must be a better way," you think.

---

## Speaker Notes - Slide 4

Kotlin asks: why do I need 50 lines for a simple bean? The answer: you don't. Kotlin removes ceremony. You keep only the logic.

Without Kotlin, you use IDE tools to generate code. With Kotlin, you write less code to begin with.

This is the thread through everything today. Kotlin = less noise, more focus on what matters.

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

## Speaker Notes - Slide 5

In Java, you write `final` by default for variables you do not want to change. But most Java developers do not. They make things mutable when immutable is safer.

Kotlin flips the default. `val` is the default - immutable. `var` for when you really need to change something.

Why does this matter? Immutable data is easier to reason about. Bugs hide in mutable state. If a variable never changes, you understand it faster. Less subtle bugs.

Example: If `name` is `val`, you know it never changes. You can read it anywhere, any time, and trust it. If it were `var`, maybe somewhere else it changed and you did not know.

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

## Speaker Notes - Slide 6

Java has `NullPointerException`. The billion dollar mistake, Tony Hoare calls it.

In Kotlin, if you declare `String`, it cannot be null. Compiler checks. If you want null, you write `String?`. Two different types in Kotlin.

This is huge. Many Java bugs are null-related. You forget to check. Code crashes in production.

In Kotlin, if you write `String?`, you MUST handle the null case. You cannot forget. The compiler forces you.

How to handle? You can check: `if (name != null) { ... }`. Or use safe call: `name?.length`. Or Elvis operator: `name?.length ?: 0`.

Without null safety, you sprinkle null checks everywhere. With Kotlin, the language helps you.

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

## Speaker Notes - Slide 7

In Java, you cannot add methods to existing classes. You write utility classes: `StringUtils.isValidEmail(email)`. Awkward.

Kotlin lets you add methods as if you wrote the class. They are called extensions.

Why? Code becomes more readable. You read like natural English: `email.isValidEmail()` instead of `StringUtils.isValidEmail(email)`.

You feel like you own the class. You can extend String, List, Map, anything. Your code becomes more fluent.

Without extensions, you have utility class layers. With extensions, the code reads better. You focus on logic, not finding the right utility class.

---

# 5. Data Classes

## Java Way (verbose)
```java
public class Person {
    private String name;
    private int age;
    
    public Person(String name, int age) { ... }
    public String getName() { ... }
    public int getAge() { ... }
    public boolean equals(Object o) { ... }
    public int hashCode() { ... }
    public String toString() { ... }
}
```

---

## Speaker Notes - Slide 8a

This is typical Java. A simple bean with two fields. How many lines? 15-20. Lots of boilerplate. IDE generates it. But you maintain it.

---

## Kotlin Way (simple)
```kotlin
data class Person(val name: String, val age: Int)
```

**That is it.** One line. Equals, hashCode, toString, copy - all automatic.

---

## Speaker Notes - Slide 8b

One line in Kotlin gives you everything: constructor, getters, equals, hashCode, toString, copy method.

Why copy? Because data is immutable by default (val). If you need to change one field, copy gives you a new object with one field changed.

```kotlin
val alice = Person("Alice", 30)
val olderAlice = alice.copy(age = 31)
```

Same alice. New object olderAlice with different age. No side effects.

Without data classes, you write tons of code. With data classes, you focus on the data shape. The ceremony vanishes.

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

## Java Promise Hell
```java
// Callback pyramid
api.getUser(user -> {
    api.getDetails(user.id, details -> {
        api.getHistory(user.id, history -> {
            println(user);
        });
    });
});
```

---

## Speaker Notes - Slide 9

Concurrency is hard in Java. Callbacks lead to pyramid code - hard to read, hard to maintain.

Kotlin coroutines let you write async code like sync code. Your function looks normal. But it suspends when waiting. The thread is free for other work.

No pyramid. No callback hell. Code reads top to bottom, just like you learned.

Without coroutines, you juggle threads, callbacks, futures. Complex. Error-prone. With coroutines, concurrency becomes readable - almost like sync code.

This is the real power move in Kotlin. Concurrency stops being a headache.

---

# Real-World Example: API Call & Display

**The Scenario:** Fetch user from API. Show result on screen. Handle errors.

```kotlin
data class User(val id: Int, val name: String)

suspend fun fetchUser(userId: Int): User {
    return api.getUser(userId)  // Suspends, no thread blocking
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

## Speaker Notes - Slide 10

This is where Kotlin shines. Look at this code:

- `data class` - one line instead of 15
- `suspend fun` - coroutine style, reads like sync
- `try/catch` - simple error handling
- Main dispatcher - code runs on UI thread, no manual posting

Compare to Java: more classes, more nesting, more callbacks.

This code is concise. It is testable. It is maintainable.

---

# Key Takeaways

1. **Immutability first** - `val` by default
2. **Null safety** - compiler helps you avoid crashes
3. **Less boilerplate** - data classes save keystrokes
4. **Readable async** - coroutines > callbacks
5. **Interop with Java** - you can use both

---

## Speaker Notes - Slide 11

Remember these points. Kotlin is not revolutionary. It is evolutionary. It keeps what works in Java. It removes what hurts.

Immutability, null safety, less boilerplate - these patterns existed elsewhere. Kotlin brought them together, made them the default, made them ergonomic.

You can mix Kotlin and Java in one project. No all-or-nothing decision.

---

# Let's Practice

**Exercise 1:** Convert a Java class to a Kotlin data class

**Exercise 2:** Use nullable vs non-nullable types

**Exercise 3:** Write a simple coroutine

*Tim and Jakub are here to help. Ask questions. No judgment.*

---

## Speaker Notes - Slide 12

Now the fun part. We practice together. Do not worry about being perfect. Kotlin syntax is friendly. You will pick it up fast.

I will give you problems. You solve them. Tim and Jakub can help if you get stuck. Ask! That is why they are here.

After exercises, you have hands-on experience. You feel Kotlin, not just hear about it.

---

# Questions?

*Let us discuss. What interests you most?*

---

## Speaker Notes - Slide 13

Final slide. Open discussion. Ask anything. Some of you might think: "This looks cool but we use Java everywhere." Fair point. But knowing Kotlin helps you understand Java better too. Modern language features, functional thinking - these ideas matter regardless of which language you use.

Also: Kotlin runs on the same JVM. Same libraries. Same servers. You can introduce it gradually.

Thank you for your time today!
