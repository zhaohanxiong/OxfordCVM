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
- Object:
  - Classes created with specific data defined
- Method:
  - Functions in a class which performs certain tasks or defines certain features for the object
  - These can be accessed commonly with ```object.method()```
- Instance
  - An occurance or initialization of an object
- Attributes:
  - Definition of is the feature/function of a class
  - Describes the class itself (class attribute), or a method of the class (instance attribute)

### Demo Using Existing Library
```
import numpy as np
arr = np.array([0, 1, 2, 3])
arr.sum()
```
- Here we use NumPy array to demonstrate basic OOP principles
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

### Demo - Class Definition
```
# define class
class my_arr:

    # class attributes
    def __init__(self):
        self.arr = []

    # method attributes
    def get_length(self):
        return(len(self.arr))

    def add(self, element):
        self.arr.append(element)

    def remove(self, index):
        self.arr.pop(index)
```
- Here is an example of a class named ```my_arr```
- The overall function of this class is to manipulate an array-like object
- It is initialized with ```__init___``` which defines the array as an empty list
- It then has 3 methods to return the length of the array, add an element, and remove an element from the array
- Notice how each method passes ```self``` as an input arguement as it array objected is shared across the entire class
- Also notice how the array itself is only initialized once

```
demo_arr = my_arr()
```
- define object using class

```
demo_arr.add(1)
print(demo_arr.arr)
# output: [1]
```
- use method to add, then print

```
demo_arr.add(2)
print(demo_arr.arr)
# output: [1 ,2]
```
- add another element

```
print(demo_arr.get_length())
# output: 2
```
- return the length

```
demo_arr.add(3)
print(demo_arr.arr)
# output: [1, 2, 3]
```
- add another element

```
demo_arr.remove(1)
print(demo_arr.arr)
# output: [1, 3]
```
- remove an element

```
demo_arr.remove(0)
print(demo_arr.arr)
# output: [3]
```
- remove another element

### Demo - Inheritance
```
# define child class
class my_arr_child(my_arr):

    # class attributes
    def __init__(self):

        # initialize the class its inherited
        super().__init__()
        self.arr = []

    # define new method attribute
    def insert(self, element, index):
        self.arr.insert(index, element)
```
- Here we define a child class by inheriting from the previous class
- This is done by passing the parent class name into this class definition ```my_arr_child(my_arr)```
- We can then initialize the current class with ```__init__``` and also initialize its parent class with ```super().__init__()```
- This class ```my_arr_child``` will have all the methods in the parent class ```my_arr```
- We have also defined a new method exclusively available to this class, ```insert``` which allows us to insert elements into an array

```
demo_arr2 = my_arr_child()
demo_arr2.add(1)
demo_arr2.add(2)
demo_arr2.insert(10, 1)
demo_arr2.remove(0)
print(demo_arr2)
print(demo_arr2.arr)
# output: [10, 2]
```
- A new object can be initialized with the new class
- The new object is able to access methods from its parent class without repeating the code
