type
    BinaryTree*[T] = ref object
        left, right: BinaryTree[T]
        data: T

proc newLeaf*[T](data: T): BinaryTree[T] =
    return BinaryTree[T](data: data)

proc newNode*[T](left, right: BinaryTree[T]): BinaryTree[T] =
    return BinaryTree[T](left: left, right: right)

proc isLeaf*[T](node: BinaryTree[T]): bool =
    return node.data != nil
