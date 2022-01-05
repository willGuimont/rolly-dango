import std/tables
import std/packedsets
import std/hashes
import std/sequtils
import std/macros
import std/sugar

type
  Entity* = uint32
  Component* = ref object of RootObj
  ComponentStore* = TableRef[Entity, Component]
  Registry* = ref object
    lastEntityId: Entity
    validEntities: PackedSet[Entity]
    toDestroyEntities: PackedSet[Entity]
    components: TableRef[Hash, ComponentStore]

proc newRegistry*(): Registry =
  result = Registry()
  result.lastEntityId = 0
  result.components = newTable[Hash, ComponentStore]()

proc len*(reg: Registry): int =
  result = card(reg.validEntities)

proc newEntity*(reg: Registry): Entity =
  let newId = reg.lastEntityId
  reg.validEntities.incl(reg.lastEntityId)
  reg.lastEntityId.inc
  return newId

proc isEntityValid*(reg: Registry, entity: Entity): bool =
  return entity in reg.validEntities

proc destroyEntity*(reg: Registry, entity: Entity) =
  reg.validEntities.excl(entity)
  reg.toDestroyEntities.excl(entity)
  for tablesKey in reg.components.keys:
    reg.components[tablesKey].del(entity)

proc allEntities*(reg: Registry): seq[Entity] =
  result = @[]
  for e in reg.validEntities:
    result.add(e)

proc markToDestroy*(reg: Registry, entity: Entity) =
  reg.toDestroyEntities.incl(entity)

proc destroyMarkedEntities*(reg: Registry) =
  for e in reg.toDestroyEntities:
    reg.destroyEntity(e)

proc addComponent*[T](reg: Registry, entity: Entity, component: T) =
  let componentHash = ($T).hash()
  if not reg.components.hasKey(componentHash):
    reg.components[componentHash] = newTable[Entity, Component]()
  reg.components[componentHash][entity] = component

proc removeComponent*[T](reg: Registry, entity: Entity) =
  let componentHash = ($T).hash()
  if reg.components.hasKey(componentHash):
    reg.components[componentHash].del(entity)

proc getComponent*[T](reg: Registry, entity: Entity): T =
  let componentHash = ($T).hash()
  if not reg.components.hasKey(componentHash):
    raise newException(ValueError, "No component store for component of type " & $T)
  if not entity in reg.validEntities:
    raise newException(ValueError, "Entity " & $entity & " is not a valid entity")
  if not reg.components[componentHash].hasKey(entity):
    let message = "Entity " & $entity & " has not component of type " & $T
    raise newException(ValueError, message)
  return (T)reg.components[componentHash][entity]

macro getComponents*(reg: Registry, entity: Entity, componentTypes: varargs[
    untyped]): untyped =
  var tuplesElements: seq[NimNode] = @[]
  for c in componentTypes:
    let getComp = quote do:
      `reg`.getComponent[:`c`](`entity`)
    tuplesElements.add(getComp)
  result = nnkTupleConstr.newTree(tuplesElements)

proc hasComponent*[T](reg: Registry, entity: Entity): bool =
  let componentHash = ($T).hash()
  if not reg.components.hasKey(componentHash):
    return false
  if not entity in reg.validEntities:
    return false
  return reg.components[componentHash].hasKey(entity)

macro hasAllComponents*(reg: Registry, entity: Entity, componentTypes: varargs[
    untyped]): untyped =
  ## Generates an expression of the form `true and reg.hasComponent[:t1](entity) and ... and reg.hasComponent[:tn](entity)`
  ## The components should be ordered from more general (more numerous), to the more specific
  result = newLit(true)
  for c in componentTypes:
    let hasComp = quote do:
      `reg`.hasComponent[:`c`](`entity`)
    result = infix(result, "and", hasComp)

macro entitiesWith*(reg: Registry, componentTypes: varargs[untyped]): untyped =
  result = quote do:
    filter(`reg`.allEntities, e => `reg`.hasAllComponents(e, `componentTypes`))

macro makeComponentTypes(componentTypes: varargs[untyped]): untyped =
  var tuplesElements: seq[NimNode] = @[]
  for c in componentTypes:
    tuplesElements.add(ident($c))
  result = nnkTupleConstr.newTree(tuplesElements)

macro entitiesWithComponents*(reg: Registry, componentTypes: varargs[
    untyped]): untyped =
  result = quote do:
    map(`reg`.entitiesWith(`componentTypes`), e => `reg`.getComponents(e,
        `componentTypes`))
