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

    reg.addComponent(entity, component)

    check reg.hasComponent[:TestComponent](entity)
    check reg.getComponent[:TestComponent](entity) == component

  test "can remove component from entity":
    var reg = newRegistry()
    var entity = reg.newEntity()
    var component = TestComponent(x: 1, y: 2)
    reg.addComponent(entity, component)

    reg.removeComponent[:TestComponent](entity)

    check not reg.hasComponent[:TestComponent](entity)

  test "can remove entity":
    var reg = newRegistry()
    var entity = reg.newEntity()
    var component = TestComponent(x: 1, y: 2)
    reg.addComponent(entity, component)

    reg.destroyEntity(entity)

    check not reg.isEntityValid(entity)
    expect ValueError:
      # also deletes the components
      discard reg.getComponent[:TestComponent](entity)

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
    reg.addComponent(entity1, component1)
    reg.addComponent(entity1, component2)
    reg.addComponent(entity2, component2)

    check reg.hasAllComponents(entity1)
    check reg.hasAllComponents(entity1, TestComponent)
    check reg.hasAllComponents(entity1, TestComponent, OtherComponent)
    check not reg.hasAllComponents(entity2, TestComponent)
    check not reg.hasAllComponents(entity2, TestComponent, OtherComponent)

  test "can iterate on entities with components":
    var reg = newRegistry()
    var entity1 = reg.newEntity()
    var entity2 = reg.newEntity()
    var entity3 = reg.newEntity()
    var component1 = TestComponent(x: 1, y: 2)
    var component2 = OtherComponent(z: 3)
    reg.addComponent(entity1, component1)
    reg.addComponent(entity1, component2)
    reg.addComponent(entity2, component2)
    reg.addComponent(entity3, component1)

    let foundEntities = reg.entitiesWith(TestComponent)

    check entity1 in foundEntities
    check not (entity2 in foundEntities)
    check entity3 in foundEntities