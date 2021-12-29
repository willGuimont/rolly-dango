import unittest
import cart/ecs/ecs

suite "ecs":
  type
    TestComponent = ref object of Component
      x: int
      y: int
    OtherComponent = ref object of Component
      z: int

  test "can add component to entity":
    var reg = newRegistry()
    var entity = reg.newEntity()
    var component = TestComponent(x: 1, y: 2)

    addComponent(reg, entity, component)

    check hasComponent[TestComponent](reg, entity)
    check getComponent[TestComponent](reg, entity) == component

  test "can remove component from entity":
    var reg = newRegistry()
    var entity = reg.newEntity()
    var component = TestComponent(x: 1, y: 2)
    addComponent(reg, entity, component)

    removeComponent[TestComponent](reg, entity)

    check not hasComponent[TestComponent](reg, entity)

  test "can remove entity":
    var reg = newRegistry()
    var entity = reg.newEntity()
    var component = TestComponent(x: 1, y: 2)
    addComponent(reg, entity, component)

    reg.destroyEntity(entity)

    check not reg.isEntityValid(entity)
    expect ValueError:
      # also deletes the components
      discard getComponent[TestComponent](reg, entity)

  test "can delete marked entities":
    var reg = newRegistry()
    var entity1 = reg.newEntity()
    var entity2 = reg.newEntity()

    reg.markToDestroy(entity1)
    reg.destroyMarkedEntities()

    check not reg.isEntityValid(entity1)
    check reg.isEntityValid(entity2)

  test "can check if entities has all components":
    var reg = newRegistry()
    var entity1 = reg.newEntity()
    var entity2 = reg.newEntity()
    var component1 = TestComponent(x: 1, y: 2)
    var component2 = OtherComponent(z: 3)
    addComponent(reg, entity1, component1)
    addComponent(reg, entity1, component2)
    addComponent(reg, entity2, component2)

    check hasAllComponents(reg, entity1)
    check hasAllComponents(reg, entity1, TestComponent)
    check hasAllComponents(reg, entity1, TestComponent, OtherComponent)
    check not hasAllComponents(reg, entity2, TestComponent)
    check not hasAllComponents(reg, entity2, TestComponent, OtherComponent)
