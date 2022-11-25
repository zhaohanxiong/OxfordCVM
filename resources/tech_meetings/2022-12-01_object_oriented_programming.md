### Object Oriented Programming
- Object oriented programming (OOP) aims to:
  - Keep code tidy
  - Reduce repeat of code
  - Promote re-use of code
  - Isolate code for ease of use and testing
  - Make code easier to refactor or translate to new tasks
- Python is an OOP programming language
- R has OOP properties but uses unconventional syntax
- Other common OOP languages include C++, Java (Android), Swift (iOS)

### Main Terminology
- Class:
  - Data types that acts as the "framework" for objects, attributes, and methods
- Attributes:
  - Definition of what information is stored in a class
- Object:
  - Classes created with specific data defined
- Method:
  - Functions in a class which performs certain tasks or defines certain features for the object
  - These can be accessed commonly with ```object.method()```
- Instance
  - An occurance or initialization of an object

### Demo Using Existing Library
```
import numpy as np
arr = np.array([0, 1, 2, 3])
arr.sum()
```
- Here we use NumPy array to demonstrate OOP
- NumPy array is a class
- NumPy array classes has a set of attributes related to it which are implemented inside the NumPy Library
- When we define a variable ```arr``` with a NumPy array, we define an object
- We can use methods in the NumPy such as ```arr.sum()``` which allows us to return the sum of the object
- In this example, an instance is also defined when we created the object

### Main Concepts of OOP
- Encapsulation
  - All information is stored inside an object
  - Information cannot be accessed by other object
  - Only public methods can be accessed
  - Keeps object neatly packed and avoids unexpected changes
- Abstraction
  - Only useful parts of the code are shown
  - Unnecessary code is hidden
  - Allows ease of change and additions over time
- Inheritence
  - Reusing code from other classes to reuse common logic
  - Reduces development time
  - Maintains quality of code
- Polymorphism
  - Objects share behaviours and can take on more than one form
  - Allows different types of objects to pass through the same interface

### Demo Using Existing Library
```
```
