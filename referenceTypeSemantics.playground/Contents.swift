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