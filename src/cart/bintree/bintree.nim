type
    BinaryTree* = ref object
        left, right: BinaryTree
        data: int8

proc newLeaf*(data: int8): BinaryTree =
    return BinaryTree(data: data)

proc newNode*(left, right: BinaryTree): BinaryTree =
    return BinaryTree(left: left, right: right, data: -1)

proc isLeaf*(node: BinaryTree): bool =
    return node.data != -1

proc getData*(node: BinaryTree): int8 =
    return node.data

proc getLeft*(node: BinaryTree): BinaryTree =
    return node.left

proc getRight*(node: BinaryTree): BinaryTree =
    return node.right
