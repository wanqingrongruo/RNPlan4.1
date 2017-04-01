//: Playground - noun: a place where people can play

import UIKit

var str = "理解值语义的自定义类型"

//: # 理解值语义的自定义类型

//: ## 都是修改对象属性惹的祸

//: #### 一个可修改的引用语义常量
let numbers: NSMutableArray = [1, 2, 3, 4, 5]


for _ in numbers {
  //  numbers.removeLastObject() // will be cash
    
    // swift 中 NSMutableArray 是个 类对象, let 约定 numbers 不能再引用其他的类对象,并不约定类对象的属性是否可以修改
    // 因为在Swift里，通过for遍历数组是通过while和Iterator模拟出来的
//    var numberIter = numbers.makeIterator()
//    
//    while let number = numberIter.next() {
//        numbers.removeLastObject()
//    }
    
   // 对于numberIter来说，它的实现直接访问了NSMutableArray的底层数据存储，而当我们从numbers中删除元素的同时，也会破坏掉numberIter内部用于遍历数组的状态。因此，删掉一个元素之后，再调用numberIter.next()，就发生运行时错误了。这也就意味着，所有调用了removeLastObject()方法的API都会有上面类似的问题。
}

//: #### 一个不可修改的值语义常量

let numsSwift = [1, 2, 3, 4, 5]
for _ in numsSwift {
   // numsSwift.removeLast() // compile error
    
    // Swift中Array的Iterator在内部保存了一个Array的副本，这个副本和numbers是分开独立的，而for循环迭代的，实际上是这个副本。因此，尽管我们在循环里不断的在numbers末尾删除元素，也不会造成运行时错误。
}

//: #### 对多线程环境里修改共享的类对象保持谨慎

class Queue {
    var position = 0
    var array: [Int] = []
    
    init(_ array: [Int]) {
        self.array = array
    }
    
    func next() -> Int? {
        
        guard position < array.count else {
            return nil
        }
        
        position += 1
        
        return array[position - 1]
    }
}

func traverseQueue(_ queue: Queue) {
    
    while let item = queue.next() {
        print(item)
    }
}

let q = Queue([1, 2, 3, 4, 5])
traverseQueue(q)

for _  in 0...1000 {
    let qq = Queue([1, 2, 3, 4, 5])
    DispatchQueue.global().async {
       // traverseQueue(qq) // maybe crash here
    }
    
  //  traverseQueue(qq) // or here
    
    // 类是引用类型
    // 主线程 和 全局队列 共用同一个 Queue 对象的引用
    
   // 由于Queue是一个引用类型，当q分别传递给主线程和全局队列时，传递的都是同一个Queue对象的引用，在next()的判断里，当guard position < array.count判断后，如果发生线程切换，在另外的线程里把position + 1，再回到之前的线程里读取Queue.array的时候，就会发生异常了。
}


//struct PhotoAsset{
//    
//    var type: String
//    var name: String
//    
//    init(_ type: String, _ name: String) {
//        self.type = type
//        self.name = name
//    }
//}
//
//extension PhotoAsset: Equatable {
//
//    public static func ==(lhs: PhotoAsset, rhs: PhotoAsset) -> Bool{
//        
//        if lhs.name == rhs.name && lhs.type == rhs.type {
//            return true
//        }
//        
//        return false
//    }
//}
//
//
//let p1 = PhotoAsset("mac", "roni")
//let p2 = PhotoAsset("win", "xia")
//let p3 = PhotoAsset("mac", "roni")
//
//let photos = [p1, p2]
//photos.contains(p3)


//: ## 定义更复杂的值 - struct

/*:
 * #### 应该在什么地方使用 struct
 * 一类是必须有明确生命周期的，它们必须被明确的初始化、使用、最后明确的被释放。例如：文件句柄、数据库连接、线程同步锁等等。这些类型的初始化和释放都不是拷贝内存这么简单，通常，这类内容，我们会选择使用class来实现。
 * 另一类，则是没有那么明显的生命周期，例如：整数、字符串、URL等等。这些对象一旦被创建之后，就很少被修改，我们只是需要使用这些对象的值，用完之后，我们也无需为这些对象的销毁做更多额外的工作，只是把它们占用的内存回收就好了。这类内容，通常我们会选择使用struct或enum来实现
 */

//: #### struct 的定义和初始化

struct Point {
    var x: Double
    var y: Double
    
    // 如果你不创建任何init方法，Swift编译器就会为你自动创建一个，让你可以逐个初始化struct中的每一个属性
    // 这个 init 方法也叫 memberwise initializer
    
    // 自己创建 init
    init(_ x: Double = 0.0, _ y: Double = 0.0) {
        self.x = x
        self.y = y
    }
    
    init(_ pt: (Double, Double)) {
        self.x = pt.0
        self.y = pt.1
    }
    
    // type property 
    // 它不是 struct 对象的一部分, 不会增大 Point 对象的大小
    static var origin = Point((0,0))
}

//var pointA = Point(x: 100, y: 200)
var pointB = Point()
var pointC = Point((100,300))

Point.origin

Point.origin = Point((200, 300))

//: #### 理解 struct 的值语义

var pointD = Point(100, 200) {
    
    willSet {
        print("PointD will change")
    }
    didSet {
        print("PointD changed: \(pointD)")
    }
    
}

pointD = pointC

// 即便一个struct属性的类型是var，修改它在语义上也是创建一个新的struct对象。
pointD.x += 400

//: #### 为 struct 添加方法
extension Point {
    
    func distance(to: Point) -> Double {
        
        let distX = self.x - to.x
        let disY = self.y - to.y
        
        return sqrt(distX * distX + disY * disY)
    }
    
    // 使用mutating -- Swift编译器就会在所有的mutating方法第一个参数的位置，自动添加一个inout Self参数：
    mutating func move(/*self: inout Self*/ to: Point) {
        
        self = to
    }
}


pointD.distance(to: Point.origin)

pointD.move(to: pointB)


//: ## 不再只是“值替身”的enum

enum Direction: Int{
    case east = 2
    case south = 4
    case west = 6
    case north = 8
}

enum Month: Int{
    case january = 1, februray, march,
    april, may, june, july,
    august, september, october,
    november, december
}

func direction(val: Direction) -> String {
    switch val {
    case .north, .south:
        return "up down"
    case .east, .west:
        return "left right"
    }
}


//Swift的enum默认不会为它的case“绑定”一个整数值。但这并不妨碍你手工给case“绑定”一个，而这样“绑定”来的值，叫做raw values

let NORTH = Direction.north.rawValue
let MONTH = Month.january.rawValue

//: #### Associated value

enum HTTPAction {
    case get
    case post(String)
    case delete(Int, String)
}

var action1 = HTTPAction.get
var action2 = HTTPAction.post("BOXUE")

// 1. 不是每一个case必须有associated value，例如.get就只有自己的enum value；
// 2. 当我们想“提取”associated value的所有内容时，我们可以把let或var写在case后面，例如.post的用法；
// 3. 当我们想分别“提取”associated value中的某些值时，我们可以把let或var写在associated value里面，例如.delete的用法；

switch action1 {
case .get:
    print("HTTP GET")
case let .post(para):
    print("\(para)")
case .delete(let id, let data):
    print("id = \(id), data = \(data)")
}

//: enum 是一个值类型, 也可以是一个引用类型

// 在Swift里，enum默认也是一个值类型，也就说，每一个enum对象，都只能有一个owner，因此，你无法创建指向同一个enum对象的多个引用。

// 但有一种特殊的情况，可以改变enum的这个属性

enum List {
    case end
    indirect case node(Int, next: List)
    // 我们可以使用indirect修饰一个case，这样当一个List为case node时，它就变成了一个引用类型，多个case node可以指向同一个List对象
}

// 此时，list1和list2就指向了同一个end对象。
let end = List.end
let list1 = List.node(1, next: end)
let list2 = List.node(2, next: end)

