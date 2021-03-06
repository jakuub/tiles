library tiles_dom_component_test;

import 'package:unittest/unittest.dart';
import 'package:tiles/tiles.dart';
import '../mocks.dart';

main() {
  
  group("(DomComponent)", () {
    Map props;
    
    setUp(() {
      props = new Map();
    });
    
    test("constructor should create props equals that in constructor and pair component by default", () {
      DomComponent component = new DomComponent(props);
      expect(component, isNotNull);
      expect(component.props, equals(props));
      expect(component.pair, isTrue);
      
      /**
       * check inherited constructor behaviour
       */
      expect(component.needUpdate, isNotNull);
    });
    
    test("constructor should create not pair element if pair argument is false", () {
      DomComponent component = new DomComponent(props, null, null, false);
      expect(component.pair, isFalse);
    });

    test("constructor should create pair element if pair argument is true", () {
      DomComponent component = new DomComponent(props, null, null, null, true);
      expect(component.pair, isTrue);
    });
    
    test("constructor without svg flag should create not svg component", () {
      DomComponent component = new DomComponent(null);
      
      expect(component.svg, isFalse);
    });
    
    test("svg should be readonly", () {
      DomComponent component = new DomComponent(null);

      expect(() => component.svg = true, throws, reason: "svg should be readonly");
    });
    
    test("should create svg component if in controller is svg = true", () {
      DomComponent component = new DomComponent(null, null, null, null, true);
      
      expect(component.svg, isTrue);
    });
    
    test("render should return children", () {
      var children = [new ComponentDescriptionMock(), new ComponentDescriptionMock()];

      DomComponent component = new DomComponent(props, children);
      
      expect(component.render(), equals(children));
    });
    
    test("should throw with not map props in constructor", () {
      expect(() => new DomComponent("string props"), throws);
    });


  });
  
}

