//: Playground - noun: a place where people can play

import UIKit

var str = "理解引用语义的自定义类型"

//: ## 差异于语法之外的struct和class

struct PointValue {
    var x: Int
    var y: Int
    
    // 自动生成默认的 init 方法
}

class PointRef {
    var x: Int
    var y: Int
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

//: 1. 引用类型必须明确指定 init 方法

//: 2. 引用类型关注的是对象本身

let p1 = PointRef(x: 0, y: 0)
let p2 = PointValue(x: 0, y: 0)

//常量的意义当然是：“它的值不能被改变”。但是p1作为一个引用类型，常量的意义则变成了，它可以修改自身的属性，但不能再引用其他的PointRef对象
// p2.x = 20
p1.x = 10

// p1 = PointRef(x: 1, y: 1)

var p3 = p1
var p4 = p2

p1 === p3

p3.x = 10
p1.x

p4.x = 20
p2.x


//: 3. 引用类型默认是可以修改的

extension PointRef {
    // 由于引用类型关注的是其引用的对象，而不是对象的值。因此，它的方法默认是可以修改对象属性的
    // 不需要使用 mutatiing
    func move(to: PointRef){
        
        self.x = to.x
        self.y = to.y
        
        // 在class的方法里，self 自身是一个常量，我们不能直接让它引用其它的对象
        // self = to // !! Compile time error !!
    }
}

extension PointValue {
    
    // 需要使用 mutatiing
    mutating func move(to: PointRef){
        
        self.x = to.x
        self.y = to.y
        
        // 直接给 self 赋值也是可以的
        // 编译器知道对一个值类型赋值就是简单的内存拷贝
        // self = to
    }

}

//: ## 理解 class 类型的各种 init 方法

class Point2D {
    var x: Double
    var y: Double 
    
    // 定义默认的 init
    
    // 1. 方法一, 给每个属性添加默认值
    // 2. 方法二, memberwise init方法
    init(x: Double = 0, y: Double = 0) {
        self.x = x
        self.y = y
    }
    
}

let origin = Point2D()
let point11 = Point2D(x: 11, y: 11)