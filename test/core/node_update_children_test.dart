library tiles_node_update_children_test;

import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:tiles/tiles.dart';
import '../mocks.dart';
import 'dart:async';


main() {
  
//  var component = new ComponentMock()
//    ..when(callsTo('render')).alwaysReturn([]);
//  
//  component.getLogs(callsTo('componentWillReceiveProps')).verify(happenedOnce);
  group("(Node)", () {
    ComponentDescriptionMock description;
    ComponentDescriptionMock description2;
    ComponentMock component;
    Node node;
    List<NodeChange> changes;
    
    ComponentDescriptionMock createDefaultDescription() {
      ComponentDescriptionMock description = new ComponentDescriptionMock();

      description.when(callsTo("createComponent")).alwaysReturn(new ComponentMock());
      description.when(callsTo("get factory")).alwaysReturn(([dynamic props, children]) => new ComponentMock());
      
      return description;
    }
    
    setUp(() {
      description = createDefaultDescription();
      description2 = createDefaultDescription();
      component = new ComponentMock();
      
      component.when(callsTo("render")).alwaysReturn([description]);
      
    });
    
    eraseComponent() {
      component = new ComponentMock();
    }
    
    void createNode() {
      node = new Node(null, component);
      changes = node.update();
      
    }
    
    void updateNode() {
      node.isDirty = true;
      changes = node.update();
    }
    
    group("(simple update)", () {
  
      /**
       * test node with component, which render always return description with same factory.
       */
      test("update - component will return description of one component, node should have one child", () {
        createNode();
        
        /**
         * test if changes are as they should be - updated, created child and updated child.
         */
        expect(changes.length, equals(2));
        expect(changes.first.type, equals(NodeChangeType.UPDATED));
        expect(changes.first.node, equals(node));
        expect(changes[1].type, equals(NodeChangeType.CREATED));
        expect(changes[1].node, isNot(node));
        
        /**
         * try, if node has children as they should
         */
        expect(node.children.isNotEmpty, isTrue);
        expect(node.children.length, equals(1));
        
        /**
         * and then try another update
         * as node is not dirty, and don't have dirty descendatns, 
         * no change is generated 
         */
      });
      
      test("update - if no apply called, update will do no change", () {
        createNode();
        
        changes = node.update();
        expect(changes, isEmpty);
        
      });
      
      test("update - node with dirty child, update will return only change of updated child", () {
        createNode();
        
        node.children.first.node.isDirty = true;
        
        expect(node.hasDirtyDescendant, isTrue);
        
        changes = node.update();
  
        expect(node.hasDirtyDescendant, isFalse);
        
        expect(changes.isEmpty, isFalse);
        expect(changes.length, equals(1));
        expect(changes.first.node, equals(node.children.first.node));
        expect(changes.first.type, equals(NodeChangeType.UPDATED));
  
      });
      
    });
    
    group("(_updateChildren)", () {
      test("update - if factory is the same, child will be the same", () {
        createNode();
        
        Node oldNode = node.children.first.node;
        
        node.apply();
        
        changes = node.update();
        expect(changes.isEmpty, isFalse);
        expect(changes.length, equals(2)); // both, node and it's child is updated
        
        expect(node.children.first.node, equals(oldNode));
        
      });
      
      test("update - when factory is different, child will be replaced", () {
        /**
         * return every time new factory
         */
        description.when(callsTo("get factory"))
          .thenReturn(([dynamic props, children]) => new ComponentMock())
          .thenReturn(([dynamic props, children]) => new ComponentMock())
          .thenReturn(([dynamic props, children]) => new ComponentMock());
        
        createNode();
        
        /**
         * node have some child
         */
        expect(node.children.isNotEmpty, isTrue);
        
        /**
         * save first child to oldChild
         */
        Node oldChild = node.children.first.node;
        
        node.apply();
  
        node.update();
        /**
         * because in RenderingAlwaysNewFactoryComponent is always created new, 
         * unique factory, node.update always replace child.
         */
        expect(node.children.first, isNot(oldChild));
      });
      
      test("update - when children was removed, remove it and create node change for it", () {
        
        eraseComponent();

        component.when(callsTo("render"))
          .thenReturn([description])
          .thenReturn([]);
        
  
        createNode();

        expect(node.children.isEmpty, isFalse);
        
        updateNode();
        /**
         * expect there are 2 updates, first update of node and second of removing it's child
         */
        expect(changes.length, equals(2));
        expect(changes.first.type, equals(NodeChangeType.UPDATED));
        expect(changes.last.type, equals(NodeChangeType.DELETED));
        
        /**
         * and that child was removed
         */
        expect(node.children.isEmpty, isTrue);
        
      });
      
      group("(key)", () {
        String key1 = "kye1";
        String key2 = "key2";
        
        setUp(() {
          eraseComponent();
          
          component.when(callsTo("render"))
            .thenReturn([description, description2])
            .thenReturn([description2, description]);
          
        });
        
        countChangeTypes(List<NodeChange> changes, NodeChangeType type) {
          num count = 0;
          changes.forEach((change) => change.type == type ? count++ : 0);
          return count;
        }
        
        addKey(ComponentDescriptionMock description) {
          description.when(callsTo("get key")).alwaysReturn(new Mock());
        }
        
        createAndUpdateNode() {
          createNode();
          
          updateNode();
        }
        
        test("should replace both node if was returned 2 descriptions in different order each time", () {
          createNode();

          expect(node.children.length, equals(2));

          var child1 = node.children.first;
          var child2 = node.children.last;
          
          updateNode();
          
          expect(node.children.length, equals(2));
          expect(node.children.first, isNot(equals(child1)));
          expect(node.children.first, isNot(equals(child2)));
          expect(node.children.last, isNot(equals(child1)));
          expect(node.children.last, isNot(equals(child2)));
          
        });
        
        test("should only change order when return two descriptions with keys in different order", () {
          addKey(description);
          addKey(description2);
          
          createNode();
          
          expect(node.children.length, equals(2));

          var child1 = node.children.first;
          var child2 = node.children.last;
          
          updateNode();
          
          expect(node.children.length, equals(2));
          
          expect(node.children.first, equals(child2));
          expect(node.children.last, equals(child1));

          expect(node.children.first, isNot(equals(child1)));
          expect(node.children.last, isNot(equals(child2)));
        });

        test("should move child with key and replace one without key where was with key moved", () {
          addKey(description);
          
          createNode();
          
          expect(node.children.length, equals(2));

          var child1 = node.children.first;
          var child2 = node.children.last;
          
          updateNode();
          
          expect(node.children.length, equals(2));
          
          expect(node.children.last, equals(child1));

          expect(node.children.first, isNot(equals(child2)));
          expect(node.children.first, isNot(equals(child1)));
          expect(node.children.last, isNot(equals(child2)));
        });
        
        test("should produce node changes with move, when both of 2 children have keys", () {
          addKey(description);
          addKey(description2);
          
          createAndUpdateNode();
          
          num countOfMove = countChangeTypes(changes, NodeChangeType.MOVED);
          num countOfCreate = countChangeTypes(changes, NodeChangeType.CREATED);
          num countOfDelete = countChangeTypes(changes, NodeChangeType.DELETED);
          
          expect(changes.length, equals(5), reason: "there should be 5 changes");
          expect(countOfMove, equals(2), reason: "two of five updates should be move");
          expect(countOfCreate, equals(0));
          expect(countOfDelete, equals(0));
        });
      
        test("should produce node changes with 1 move and 1 delete and 1 delete, when 1 child have key", () {
          addKey(description);
          
          createAndUpdateNode();
          
          num countOfMove = countChangeTypes(changes, NodeChangeType.MOVED);
          num countOfCreate = countChangeTypes(changes, NodeChangeType.CREATED);
          num countOfDelete = countChangeTypes(changes, NodeChangeType.DELETED);
          
          expect(changes.length, equals(5), reason: "there should be 6 changes");
          expect(countOfMove, equals(1), reason: "1 of 6 updates should be move");
          expect(countOfCreate, equals(1));
          expect(countOfDelete, equals(1));
        });
        
        test("should correctly change more complex structure of children and return correct changes", () {
          eraseComponent();
          
          ComponentDescriptionMock d0 = createDefaultDescription();
          ComponentDescriptionMock d1 = description;
          ComponentDescriptionMock d2 = description2;
          ComponentDescriptionMock d3 = createDefaultDescription();
          ComponentDescriptionMock d4 = createDefaultDescription();
          ComponentDescriptionMock d5 = createDefaultDescription();
          ComponentDescriptionMock d6 = createDefaultDescription();
          ComponentDescriptionMock d7 = createDefaultDescription();
          
          ComponentDescriptionMock dk1 = createDefaultDescription();
          addKey(dk1);
          
          ComponentDescriptionMock dk2 = createDefaultDescription();
          addKey(dk2);
          
          component.when(callsTo("render"))
            .thenReturn([d0, d1, d2,  d3, dk1, d5,  d6, dk2])
            .thenReturn([d0, d1, dk2, d3, d4,  dk1, d6, d7]);

          createNode();
          
          List<NodeChild> children = node.children;
          
          updateNode();
          
          print(changes.length);

          expect(countChangeTypes(changes, NodeChangeType.MOVED), equals(2));
          expect(countChangeTypes(changes, NodeChangeType.UPDATED), equals(7));
          expect(countChangeTypes(changes, NodeChangeType.CREATED), equals(2));
          expect(countChangeTypes(changes, NodeChangeType.DELETED), equals(2));
          
          /**
           * [d0, d1, d2,  d3, dk1, d5,  d6, dk2]
           *  ||  ||  *    ||  *    *    ||  *   
           * [d0, d1, dk2,  d3, d4,  dk1, d6, d7]
          */
          expect(node.children[0], equals(children[0]));
          expect(node.children[1], equals(children[1]));
          expect(node.children[2], isNot(equals(children[2])));
          expect(node.children[3], equals(children[3]));
          expect(node.children[4], isNot(equals(children[4])));
          expect(node.children[5], isNot(equals(children[5])));
          expect(node.children[6], equals(children[6]));
          expect(node.children[7], isNot(equals(children[7])));
          
          /**
           * [d0, d1, d2,  d3, dk1, d5,  d6, dk2]
           *                    '----,
           * [d0, d1, dk2,  d3, d4,  dk1, d6, d7]
          */
          expect(node.children[5], equals(children[4]));
          /**
           * [d0, d1, d2,  d3, dk1, d5,  d6, dk2]
           *           ,----------------------'
           * [d0, d1, dk2,  d3, d4,  dk1, d6, d7]
          */
          expect(node.children[2], equals(children[7]));
        });
            
      });
      
    });
  });
}
