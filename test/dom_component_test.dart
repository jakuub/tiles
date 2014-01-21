library tiles_dom_component_test;
import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:tiles/tiles.dart';
import 'package:tiles/tiles_dom.dart';
import 'mocks.dart';
import 'dart:async';

main(){
  
  group("(DomComponent)", () {
    Props props;
    
    setUp(() {
      props = new Props();
    });
    
    test("easy consturcor without pair flag...", () {
      DomComponent component = new DomComponent(props);
      expect(component, isNotNull);
      expect(component.props, equals(props));
      expect(component.pair, isTrue);
      
      /**
       * check inherited constructor behaviour
       */
      expect(component.needUpdate, isNotNull);
    });
    
    test("constructor with pair flag false", () {
      DomComponent component = new DomComponent(props, null, null, false);
      expect(component.pair, isFalse);
    });

    test("constructor with pair flag true", () {
      DomComponent component = new DomComponent(props, null, null, true);
      expect(component.pair, isTrue);
    });
    
    test("pair component without props should reutrn <tagname> as open markup and </tagname> as close one", () {
      DomComponent component = new DomComponent(null, null, "tagname");
      expect(component.openMarkup(), equals("<tagname>"));
      expect(component.closeMarkup(), equals("</tagname>"));
    });
  
    test("not pair component without props should reutrn <tagname /> as open markup and null as close one", () {
      DomComponent component = new DomComponent(null, null, "tagname", false);
      expect(component.openMarkup(), equals("<tagname />"));
      expect(component.closeMarkup(), isNull);
    });
  
  });
  
}