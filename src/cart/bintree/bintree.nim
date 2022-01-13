type
    BinaryTree*[T] = ref object
        left, right: BinaryTree[T]
        data: T

proc newLeaf*[T](data: T) =
    return BinaryTree(data: data)

proc newNode*[T](left, right: BinaryTree[T]) = 
    return BinaryTree(left: left, right: right)

proc isLeaf*[T](node: BinaryTree[T]): bool =
    return node.data != nil
