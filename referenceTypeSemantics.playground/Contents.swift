////: Playground - noun: a place where people can play
//
//import UIKit
//
//var str = "理解引用语义的自定义类型"
//
////: ## 差异于语法之外的struct和class
//
//struct PointValue {
//    var x: Int
//    var y: Int
//    
//    // 自动生成默认的 init 方法
//}
//
//class PointRef {
//    var x: Int
//    var y: Int
//    init(x: Int, y: Int) {
//        self.x = x
//        self.y = y
//    }
//}
//
////: 1. 引用类型必须明确指定 init 方法
//
////: 2. 引用类型关注的是对象本身
//
//let p1 = PointRef(x: 0, y: 0)
//let p2 = PointValue(x: 0, y: 0)
//
////常量的意义当然是：“它的值不能被改变”。但是p1作为一个引用类型，常量的意义则变成了，它可以修改自身的属性，但不能再引用其他的PointRef对象
//// p2.x = 20
//p1.x = 10
//
//// p1 = PointRef(x: 1, y: 1)
//
//var p3 = p1
//var p4 = p2
//
//p1 === p3
//
//p3.x = 10
//p1.x
//
//p4.x = 20
//p2.x
//
//
////: 3. 引用类型默认是可以修改的
//
//extension PointRef {
//    // 由于引用类型关注的是其引用的对象，而不是对象的值。因此，它的方法默认是可以修改对象属性的
//    // 不需要使用 mutatiing
//    func move(to: PointRef){
//        
//        self.x = to.x
//        self.y = to.y
//        
//        // 在class的方法里，self 自身是一个常量，我们不能直接让它引用其它的对象
//        // self = to // !! Compile time error !!
//    }
//}
//
//extension PointValue {
//    
//    // 需要使用 mutatiing
//    mutating func move(to: PointRef){
//        
//        self.x = to.x
//        self.y = to.y
//        
//        // 直接给 self 赋值也是可以的
//        // 编译器知道对一个值类型赋值就是简单的内存拷贝
//        // self = to
//    }
//
//}
//
////: ## 理解 class 类型的各种 init 方法
//
//class Point2D {
//    var x: Double
//    var y: Double 
//    
//    // 定义默认的 init
//    
//    // designated init
//    // 1. 方法一, 给每个属性添加默认值
//    // 2. 方法二, memberwise init方法
//    init(x: Double = 0, y: Double = 0) {
//        self.x = x
//        self.y = y
//    }
//    
////    init?(at: (String, String)) {
////        
////        guard let x =  Double(at.0), let y =  Double(at.1) else {
////            return nil
////        }
////        self.x = x
////        self.y = y
////    }
//    
//    // convenience init
//    convenience init(at: (Double, Double)) { // 必须调用 designated init
//        self.init(x: at.0, y: at.1)
//    }
//    
//    
//    // failable init
//    convenience init?(at: (String, String)) { // 必须调用 designated init
//        guard let x = Double(at.0), let y = Double(at.1) else {
//            return nil
//        }
//        
//        // 这里，我们只要保证最终可以调用到designated init方法就好了，而不一定要在convenience init方法中，直接调用deignated init方法
//        self.init(at: (x, y))
//    }
//    
//    // 一个failable designated init方法不能被non failable convenience init调用
//
//}
//
//let origin = Point2D()
//let point11 = Point2D(x: 11, y: 11)
//
//
////: ## about inherit - two-phase initialization
//
//class Point3D: Point2D {
//    
//    var z: Double = 0
//    
//    // 1. 如果派生类没有定义任何designated initializer，那么它将自动继承继承所有基类的designated initializer
//    // 2. 如果一个派生类定义了所有基类的designated init，那么它也将自动继承基类所有的convenience init。
//   // --- 只要派生类拥有基类所有的designated init方法，他就会自动获得所有基类的convenience init方法
//    
//    // 在派生类中自定义designated init，表示我们要明确控制派生类对象的构建过程
//    init(x: Double = 0, y: Double = 0, z: Double = 0) {
//        self.z = z
//        super.init(x: x, y: y)
//        
//         self.initXYZ(x: x, y: y, z: z)
//       
//    }
//    
//    override init(x: Double, y: Double) {
//        self.z = 0
//        super.init(x: x, y: y)
//    }
//    
//    // 在派生类中，重载基类的convenience init方法，是不需要override关键字的，
//    convenience init(at: (Double, Double)) {
//        self.init(x: at.0, y: at.1, z: 0)
//    }
//    
//    // // 什么是two-phase initialization
//    // 阶段一：从派生类到基类，自下而上让类的每一个属性都有初始值
//    // 阶段二：所有属性都有初始值之后，从基类到派生类，自上而下对类的每个属性进行进一步加工
//   
//    func initXYZ(x: Double, y: Double, z: Double) {
//        self.x = round(x)
//        self.y = round(y)
//        self.z = round(z)
//    }
//}
//
//
////let point3 = Point3D(at: (3, 3))
////let point4 = Point3D(at: ("4", "4"))
//
//
//// 定义在extension中的方法，是不能被重定义的
//
//
////: ## ARC 是 如何工作的?
//
//class Person {
//    
//    let name: String
//    
//    var apartment: Apartment?
//    
//    var car: Car?
//    
//    init(name: String) {
//        self.name = name
//        
//        print("\(self.name) is being initialized")
//    }
//    
//    deinit {
//        print("\(name) is being deinitialized")
//    }
//}
//
//class Apartment {
//    
//    let unit: String
//    weak var tenant: Person?
//    
//    init(unit: String) {
//        self.unit = unit
//        
//        print("\(self.unit) is being initialized")
//    }
//    
//    deinit {
//        print("\(unit) is being deinitialized")
//    }
//}
//
//
//class Car {
//    unowned var owner: Person
//    
//    init(owner: Person) {
//        self.owner = owner
//        print("Car is being initialized.")
//    }
//    
//    deinit {
//        print("Car is being deinitialized.")
//    }
//}
//
////// 说明: ref1 变量不是类的对象本身,而是一个对象的引用, 通过它可以找到对象
////var ref1: Person? = Person(name: "roni") //  count == 1
////var ref2: Person? = ref1 // count == 2
////ref1 = nil // count == 1
////ref2 = nil // count == 0 对象被回收
//
//var roni: Person? = Person(name: "roni") // person -> count == 1
//var unit11: Apartment? = Apartment(unit: "11") // apartment -> count == 1
//
////roni?.apartment = unit11  // apartment -> count == 2
////unit11?.tenant = roni // person -> count == 2
////
////roni = nil  // person -> count == 1   -> 无法解决了
////unit11 = nil // apartment -> count == 1  -> 无法解决了
//
////: ## 使用 unowned 和 weak 处理 reference cycle
//
//// 判断标准: 根据属性是否可以为nil，我们要采取不同的方式
//
//// 一方属性可以为nil时，使用weak
//
//roni?.apartment = unit11  // strong reference
//unit11?.tenant = roni // weak refrence
//
//roni = nil  // person -> count == 1 
//unit11?.tenant
//unit11 = nil
//
//// 一方属性不可以为nil时，使用unowned
//
//var mars: Person? = Person(name: "Mars")
//// Mars is being initialized.
//var car11 = Car(owner: mars!)
//// Mars's car is being initialized.
//
//if true {
//    var mars: Person? = Person(name: "Mars")
//    var car11 = Car(owner: mars!)
//    
//    mars?.car = car11
//    mars = nil
//}

var i = 10
var captureI = { print(i) }
i = 11

// What will this print out?
captureI() // 11

class Demo {
    var value = "ddddd"
}
//
//var c = Demo()
//var captureC = { print(c.value)}
//c.value = "roni"
//
//captureC()

// 1. 无论是值类型i还是引用类型c，closure捕获到的都是它们的引用，这也是为数不多的值类型变量有引用语义的地方
// 2. Closure内表达式的值，是在closure被调用的时候才评估的，而不是在closure定义的时候评估的；

var c = Demo()
var captureC = { print(c.value) }
c.value = "updated"
c = Demo() // <-- A new object

captureC() // ""
//在调用captureC()之前，我们让c等于了一个新对象。这时captureC()就会打印一个空字符串。这说明closure捕获的是它访问的变量，也就是c的引用，而不是c引用的对象


class Role {
    var name: String
    lazy var action: () -> Void = {
        print("\(self) takes action")
    }
    
    init(_ name: String = "Foo") {
        self.name = name
        print("\(self) init")
    }
    
    deinit {
        print("\(self) deinit")
    }
}

extension Role: CustomStringConvertible {
    var description: String {
        return "<Role: \(name)>"
    }
}

if true {
    
    var boss = Role("roniiiii")
    let fn = { [weak boss] in
        print("\(boss) takes this action")
    }
    
    boss.action = fn
    
    boss.action()
}

// 只有当类对象拥有一个closure对象时，它们之间才有可能造成循环引用。


var j = 10
var captureJ = { [j] in print(j) }
j = 11

captureJ() // 10

//我们在captureI的定义中使用了[j]，这叫做closure的capture list，它的作用就是让closure按值语义捕获变量。因此，当我们执行captureJ()时，打印的结果就变成了10，这是captureJ在定义时变量j的值

