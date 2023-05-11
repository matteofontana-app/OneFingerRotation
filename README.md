

OneFingerRotation is a lightweight SwiftUI framework that enables you to add a one-finger rotation gesture to any view with a single modifier. This library is perfect for developers who want to quickly and easily implement rotation functionality in their SwiftUI applications without the hassle of dealing with complex gesture recognizers.

Current Version: **1.2.0**

---

<!--Table of Content-->
<details>
<summary>

## Table of Content

</summary>

- [Table of Content](#table-of-content)
- [Presentation](#presentation)
- [Usage](#usage)
  - [Simple Rotation](#simple-rotation)
  - [Simple Rotation with Inertia](#simple-rotation-with-inertia)
  - [Value Rotation](#value-rotation)
  - [Value Rotation with Inertia](#value-rotation-with-inertia)
  - [Auto Rotation](#auto-rotation)
  - [Value Auto Rotation](#value-auto-rotation)
  - [Value Auto Rotation with Inertia](#value-auto-rotation-with-inertia)
  - [Knob](#knob)
  - [Knob with Inertia](#knob-with-inertia)
- [Examples](#examples)
- [Versions](#versions)
- [Contributions](#contributions)
- [Next to come:](#next-to-come)
- [Donations / Support](#donations--support)
- [Contact](#contact)
- [License](#license)
</details>

## Presentation
---
## Usage

The Framework is composed of a series of modifiers that you can apply to any view in your SwiftUI project.
It is recommended to use a frame modifier with equal width and height above the frameworks modifiers, this will ensure that the rotation will take place inside of the specific view. Example:

```swift
  .frame(width: 400, height: 400)
```
Use only one modifier of the framework at a time.<br>
Here's the list of the modifiers in the framework:

<details>
<summary>

### Simple Rotation

</summary>

The Simple Rotation allows for a simple rotation using one finger.

**Declaration:**

```swift
  .simpleRotation()
```
**Customization:**

* rotationAngle: identifies the original angle of the element<br> [Type: **Angle** - Stock value: **.degrees(0)**]

* angleSnap: allows snapping using an angle factor which identifies the basic multiple of the angle<br> [Type: **Binding\<Double\>** - Stock Value: **Non declared**]
  
```swift
  .simpleRotation(
    rotationAngle: .degrees(20)
    angleSnap: .constant(60)
  )
```
</details>

<!--Simple Rotation with Inertia-->
<details>
<summary>

### Simple Rotation with Inertia

</summary>

The Simple Inertia Rotation allows the view for a simple rotation with consequent inertia effect.

**Declaration:**

Declaration should be like this:

```swift
  .simpleRotationInertia()
```

**Customization:**

These are the customization possibilities:
* friction: the inertia factor of slowdown.<br>[Type: **Binding\<Double\>** - Stock value: **0.005**] 
* velocityMultiplier: the speed multiplier of the inertia function related to the speed of the gesture on screen.<br>[Type: **Binding\<Double\>** - Stock value: **0.1**]
* decelerationFactor: the deceleration factor multiplier, big value indicates a longer inertia.<br>[Type: **Binding\<Double\>** - Stock value: **0.4**]
* rotationAngle: identifies the original angle of the element<br> [Type: **Angle** - Stock value: **.degrees(0)**]
* angleSnap: allows snapping using an angle factor which identifies the basic multiple of the angle<br> [Type: **Binding\<Double\>** - Stock Value: **Non declared**]
* angleSnapShowFactor: this variable controls the visibility during the inertia of angles not belonging to the angleSnap range.<br>[Type: **Binding\<Double\>** - Stock value: **0.1**]
  
```swift
  .simpleRotationInertia(
    friction: .constant(0.005),
    velocityMultiplier: .constant(0.1),
    decelerationFactor: .constant(0.4),
    rotationAngle: .degrees(0.0),
    angleSnap: .constant(20),
    angleSnapShowFactor: .constant(0.1)
  )
```

</details>

<!--Value Rotation-->
<details>
<summary>

### Value Rotation

</summary>
The Value Rotation allows for a simple rotation using one finger with a linked value related to the total angle of rotation.

**Setup**

To use the modifier it's necessary to create a variable of type double that will indicate the starting point of the element. Example:

```swift
  @State private var totalAngle: Double = 0.0
```

**Declaration:**

To declare the modifier it is mandatory to link the variable and also the onAngleChanged, inside of this there must be the linked variable.

```swift
  .valueRotation(
    totalAngle: $totalAngle2,
    onAngleChanged: { newAngle in
    totalAngle2 = newAngle
    }
  )
```

**Customization:**

*  animation: this parameter controls the animation during a change of totalAngle from outside the modifier.<br>[Type: **Animation** - Stock value: **Missing value**]

```swift
  .valueRotation(
    totalAngle: $totalAngle,
    onAngleChanged: { newAngle in
    totalAngle = newAngle
    },
    animation: .spring()
  )
```


</details>

<!--Value Rotation with Inertia-->
<details>
<summary>

### Value Rotation with Inertia

</summary>

The Value Rotation with Inertia allows for a rotation with value linked and inertia effect at the end of the gesture.

**Setup**

To use the modifier it's necessary to create a variable of type double that will indicate the starting point of the element. Example:

```swift
  @State private var totalAngle: Double = 0.0
```

**Declaration:**

To declare the modifier it is mandatory to link the variable and also the onAngleChanged, inside of this there must be the linked variable.

```swift
  .valueRotationInertia(
      totalAngle: $totalAngle,
      onAngleChanged: { newAngle in
      totalAngle = newAngle
    }
  )
```


**Customization:**

These are the customization possibilities:
* friction: the inertia factor of slowdown.<br>[Type: **Binding\<Double\>** - Stock value: **0.005**] 
* velocityMultiplier: the speed multiplier of the inertia function related to the speed of the gesture on screen.<br>[Type: **Binding\<Double\>** - Stock value: **0.1**]
*  animation: this parameter controls the animation during a change of totalAngle from outside the modifier.<br>[Type: **Animation** - Stock value: **Missing**]
* stoppingAnimation: this variable controls if the rotation stops after the value of knobValue changes outside the modifier. It is suggested to use a variable as it will be needed in case of this application.<br>[Type: **Binding\<Bool\>** - Stock value: **false**]

```swift
  .valueRotationInertia(
    totalAngle: $totalAngle,
    friction: .constant(0.005),
    onAngleChanged: { newAngle in
      totalAngle3 = newAngle
    },
    velocityMultiplier: .constant(0.1),
    animation: .spring(),
    stoppingAnimation: $valueChange
)
```

</details>

<!--Auto Rotation-->
<details>
<summary>

### Auto Rotation

</summary>

The Auto Rotation applies an automatic rotation to a simple rotation.

**Declaration:**

```swift
  .autoRotation()
```
**Customization:**

* rotationAngle: Identifies the original angle of the element<br> [Type: **Angle** - Stock value: **.degrees(0)**]

* autoRotationSpeed: Indicates the speed of the rotation of the content during motion.<br>[Type: **Binding\<Double\>** - Stock value: **20**]

* autoRotationActive: Indicates if the content has to rotate or not, allowing for pause of the rotation.<br>[Type: **Binding\<Bool\>** - Stock value: **true**]
  
```swift
  .autoRotation(
    rotationAngle: .degrees(20)
    autoRotationSpeed: .constant(20),
    autoRotationActive: .constant(true)
  )
```

In case there have been use of variables for the last two parameters it is possible to modify them using binding variables:

```swift
  .autoRotation(
    rotationAngle: .degrees(20),
    autoRotationSpeed: $autoRotationSpeed,
    autoRotationActive: $autoRotationActive
  )
```

Using this method will make able to modify the variables during the use of the modifier:

```swift
  Button(action: {
    autoRotationActive.toggle()
  }, label: {
    Text("Pause the Rotation")
  })

  Button(action: {
    autoRotationSpeed = [Insert double value here]
  }, label: {
    Text("Modify the speed")
  })
```

</details>

<!--Value Auto Rotation-->
<details>
<summary>

### Value Auto Rotation

</summary>

The Value Auto Rotation links a value related to the angle of an Auto Rotation

**Setup**

To use the modifier it's necessary to create a variable of type double that will indicate the starting point of the element. Example:

```swift
  @State private var totalAngle: Double = 0.0
```

**Declaration:**

To declare the modifier it is mandatory to link the variable and also the onAngleChanged, inside of this there must be the linked variable.

```swift
  .valueAutoRotation(
    totalAngle: $totalAngle,
    onAngleChanged: { newAngle in
        totalAngle = newAngle
    }
  )
```

**Customization:**

*  animation: this parameter controls the animation during a change of totalAngle from outside the modifier.<br>[Type: **Animation** - Stock value: **Missing value**]

* autoRotationSpeed: Indicates the speed of the rotation of the content during motion.<br>[Type: **Binding\<Double\>** - Stock value: **20**]

* autoRotationActive: Indicates if the content has to rotate or not, allowing for pause of the rotation.<br>[Type: **Binding\<Bool\>** - Stock value: **true**]

```swift
  .valueAutoRotation(
    totalAngle: $totalAngle,
    onAngleChanged: { newAngle in
        totalAngle = newAngle
    },
    animation: .spring(),
    autoRotationSpeed: .constant(20),
    autoRotationEnabled: .constant(true)
  )
```

At this point is also possible to add the reading of the totalAngle:
```swift
  Text("The value is: \(totalAngle)")
```

In case there have been use of variables for the last two parameters it is possible to modify them using binding variables:

```swift
  .valueAutoRotation(
    totalAngle: $totalAngle,
    onAngleChanged: { newAngle in
        totalAngle = newAngle
    },
    animation: .spring(),
    autoRotationSpeed: $autoRotationSpeed,
    autoRotationActive: $autoRotationActive
  )
```

Using this method will make able to modify the variables during the use of the modifier:

```swift
  Button(action: {
    autoRotationActive.toggle()
  }, label: {
    Text("Pause the Rotation")
  })

  Button(action: {
    autoRotationSpeed = [Insert double value here]
  }, label: {
    Text("Modify the speed")
  })
```


content
</details>

<!--Value Auto Rotation with Inertia-->
<details>
<summary>

### Value Auto Rotation with Inertia

</summary>

An Automatic rotation with finger rotation gesture and inertia effect. All in one.

**Setup**

To use the modifier it's necessary to create a variable of type double that will indicate the starting point of the element. Example:

```swift
  @State private var totalAngle: Double = 0.0
```

**Declaration:**

To declare the modifier it is mandatory to link the variable and also the onAngleChanged, inside of this there must be the linked variable.

```swift
  .valueAutoRotationInertia(
    totalAngle: $totalAngle,
    onAngleChanged: { newAngle in
    totalAngle = newAngle
    }
  )
```

**Customization**

These are the customization possibilities:

* friction: the inertia factor of slowdown.<br>[Type: **Binding\<Double\>** - Stock value: **0.005**] 
* velocityMultiplier: the speed multiplier of the inertia function related to the speed of the gesture on screen.<br>[Type: **Binding\<Double\>** - Stock value: **0.1**]
*  animation: this parameter controls the animation during a change of totalAngle from outside the modifier.<br>[Type: **Animation** - Stock value: **Missing value**]
* stoppingAnimation: this variable controls if the rotation stops after the value of knobValue changes outside the modifier. It is suggested to use a variable as it will be needed in case of this application.<br>[Type: **Binding\<Bool\>** - Stock value: false]
* autoRotationSpeed: Indicates the speed of the rotation of the content during motion.<br>[Type: **Binding\<Double\>** - Stock value: **20**]
* autoRotationActive: Indicates if the content has to rotate or not, allowing for pause of the rotation.<br>[Type: **Binding\<Bool\>** - Stock value: **true**]

```swift
  .valueAutoRotationInertia(
    totalAngle: $totalAngle,
    friction: .constant(0.1)
    onAngleChanged: { newAngle in
      totalAngle = newAngle
    },
    velocityMultiplier: .constant(0.1),
    animation: .spring(),
    stoppingAnimation: $valueChange,
    autoRotationSpeed: .constant(90),
    autoRotationEnabled: .constant(true)
  )
```

</details>

<!--Knob-->
<details>
<summary>

### Knob

</summary>

The Knob applies a range value from 0 to 1 to a certain angle interval.

**Setup:**

To use the modifier it's necessary to create a variable of type double between the range 0.0-1.0, this variable will indicate the starting point of the knob. For example in this next implementation, the knob will start from the middle point:

```swift
  @State private var knobValue: Double = 0.5
```

**Declaration:**

To declare the modifier it is mandatory to link the variable and also the onKnobValueChanged, inside of this there must be the linked variable.

```swift
  .knobRotation(
    knobValue: $knobValue,
    onKnobValueChanged: { newValue in
      knobValue = newValue
    }
  )
```

**Customization:**

* minAngle: the minimum angle of the knob.<br>[Type: **Double** - Stock value: **-90**]
* maxAngle: the maximum angle of the knob.<br>[Type: **Double** - Stock value: **+90**]
* animation: this parameter controls the animation during a change of knobValue from outside the modifier.<br>[Type: **Animation** - Stock value: **Missing value**]


```swift
  .knobRotation(
    knobValue: $knobValue,
    minAngle: -180,
    maxAngle: +180,
    onKnobValueChanged: { newValue in
      knobValue = newValue
    },
    animation: .spring()
  )
```
At this point is also possible to add the reading of the knobValue:
```swift
  Text("The value is: \(knobValue)")
```
In case there is need to change the value from outside this is the procedure ot call it:
```swift
  Button(action: {
    knobValue = 0.6
  }, label: {
    Text("Button")
  })
```

</details>

<!--Knob Inertia-->
<details>
<summary>

### Knob with Inertia

</summary>

The Knob Inertia applies inertia effect to a simple knob.

**Setup:**

To use the modifier it's necessary to create a variable of type double between the range 0.0-1.0, this variable will indicate the starting point of the knob. For example in this next implementation, the knob will start from the middle point:

```swift
  @State private var knobValue: Double = 0.5
```

**Declaration:**

To declare the modifier it is mandatory to link the variable and also the onKnobValueChanged, inside of this there must be the linked variable.

```swift
  .knobInertia(
    knobValue: $knobValue,
    onKnobValueChanged: { newValue in
      knobValue = newValue
    }
  )
```

**Customization:**

You can customize these parameters:<br>
* minAngle: the minimum angle of the knob.<br>[Type: **Double** - Stock value: **-90**]
* maxAngle: the maximum angle of the knob.<br>[Type: **Double** - Stock value: **+90**]
* friction: the inertia factor of slowdown.<br>[Type: **Binding\<Double\>** - Stock value: **0.2**]
* velocityMultiplier: the speed multiplier of the inertia function related to the speed of the gesture on screen.<br>[Type: **Binding\<Double\>** - Stock value: **0.1**]
* animation: this parameter controls the animation during a change of knobValue from outside the modifier.<br>[Type: **Animation** - Stock value: **Missing value**]
* stoppingAnimation: this variable controls if the rotation stops after the value of knobValue changes outside the modifier. It is suggested to use a variable as it will be needed in case of this application.<br>[Type: **Binding\<Bool\>** - Stock value: **false**]


```swift
@State var valueChange: Bool = false
///Other code sections
  .knobInertia(
    knobValue: $knobValue,
    minangle: -180,
    maxAngle: +180,
    friction: .constant(0.1),
    onKnobValueChanged: { newValue in
      knobValue = newValue
    },
    velocityMultiplier: .constant(0.1),
    animation: .spring(),
    stoppingAnimation: $valueChange
  )
```

At this point is also possible to add the reading of the knobValue:
```swift
  Text("The value is: \(knobValue)")
```
In case there is need to change the value from outside this is the procedure ot call it:<br>Other than sending the new value it is necessary to switch the value of valueChange like this:
```swift
  Button(action: {
    knobValue = 0.6
    valueChange = true
  }, label: {
    Text("Button")
  })
```

</details>

---
## Examples

These are some examples on use of the framework:

Girandola

Wheel

Fidget Spinner

Knob

DJ Turntable

---

## Versions

* 1.2.0: Implementation of functions of snapping for Simple Rotation, Simple Rotation with Inertia
* 1.0.0: Implementation of the modifiers: Simple Rotation, Simple Rotation with Inertia, Value Rotation, Value Rotation with Inertia, Auto Rotation, Value Auto Rotation, Value Auto Rotation with Inertia, Knob, Knob with Inertia.

---
## Contributions

Feel free to file a new issue with a respective title and description in the specific issue form. If you want you can also fill a pull request to speed up on the improvement of the framework. As the code is open source, feel free to work on the code as you like. Remember that a citation to this page and to the profile will be appreciated. Thank you!

---

## Next to come:

The angleSnap functions can be added to all the modifiers. So this will be the purpose of future updates.

---
## Donations / Support

You can support me and my work through buymeacoffee. Any help would be really appreciated!

<a href="https://www.buymeacoffee.com/matteofontana" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/arial-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

---
## Contact

In case you are interested in collaborations or commisions, you can contact me through these channels:

Mail: matteofontana@matteofontana.app<br>
Website: matteofontana.app

---
## License

MIT License

Copyright (c) 2023 Matteo Fontana

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Copyright (c) 2023 Matteo Fontana
