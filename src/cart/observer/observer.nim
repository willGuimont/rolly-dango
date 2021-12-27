import sequtils
import options

type
    Observer = object
    Subject[T] = object
        observers: seq[Observer]