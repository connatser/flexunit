package flex.lang.reflect.cases
{
	import flex.lang.reflect.Method;
	
	import org.flexunit.Assert;
	
	public class MethodCase
	{
		// testable object						
		private var method:Method;
		
		// xml data to test with
		private var methodXML:XML; 
			
		[Before]
		public function setup():void {
			methodXML = <method name="myTestMethod" declaredBy="flex.lang.reflect.cases::MethodCase" returnType="void">
							<metadata name="Test">
								<arg key="description" value="ensure that setting layoutImpl makes the appropriate calls"/>
							</metadata>
						</method>;  
			method = new Method( methodXML );
		}
		
		[After]
		public function tearDown():void {
			methodXML = null;
			method = null;
		}
		
		[Test(description='ensure method name gets initialized properly')]
		public function check_initialize_name():void {
			Assert.assertEquals( "myTestMethod", method.name );
		}
		
		[Test(description='ensure methodXML variable gets initialized properly')]
		public function check_initialize_methodXML():void {
			Assert.assertEquals( methodXML, method.methodXML );
		}
		
		[Test(description="ensure delcaring Class is retrieved properly")]
		public function check_get_declaredBy():void {
			method = new Method( methodXML );
			var declaringClass:Class = method.declaringClass;
			var testClass:* = new declaringClass();
			Assert.assertTrue( testClass is MethodCase );
		}
		
		[Test(description='ensure isStatic variable gets initialized properly')]
		public function check_initialize_isStatic_false():void {
			Assert.assertFalse( method.isStatic );
		}
		
		[Test(description='ensure isStatic variable gets initialized properly')]
		public function check_initialize_isStatic_true():void {
			method = new Method( methodXML, true );
			Assert.assertTrue( method.isStatic );
		}
		
		[Test(description="ensure one metada is retrieved properly when using metadata getter")]
		public function check_get_one_metadata():void {
			var metadataXMLStr:String = "<metadata name=\"Test\">" +
										"<arg key=\"description\" value=\"my description\"/>" +
									"</metadata>";
																		
			var methodXMLStr:String = "<method name=\"myMethod\" declaredBy=\"flex.lang.reflect.cases::MethodCase\" returnType=\"void\">" + 
									metadataXMLStr +
								"</method>";
			var methodXML:XML = XML( methodXMLStr );
			
			method = new Method( methodXML );
			
			var xmlListStrExpected:String = XMLList( metadataXMLStr ).toString();
			var xmlListStrActual:String = method.metadata.toString();
			Assert.assertEquals( xmlListStrExpected, xmlListStrActual );
		}
		
		[Test(description="ensure multiple metadata are retrieved properly")]
		public function check_get_multiple_metadata():void {
			var metadataXMLStr:String = "<metadata name=\"Test\">" +
										"<arg key=\"description\" value=\"my description\"/>" +
									"</metadata>" +
									"<metadata name=\"ArrayElementType\">" +
										"<arg key=\"\" value=\"Object\"/>" +
									"</metadata>";
									
			var methodXMLStr:String = "<method name=\"myMethod\" declaredBy=\"flex.lang.reflect.cases::MethodCase\" returnType=\"void\">" + 
									metadataXMLStr +
								"</method>";
			var methodXML:XML = XML( methodXMLStr );
			
			method = new Method( methodXML );
			
			var xmlListStrExpected:String = XMLList( metadataXMLStr ).toString();
			var xmlListStrActual:String = method.metadata.toString();
			Assert.assertEquals( xmlListStrExpected, xmlListStrActual );
		}
		
		 /* This test fails when I think it should pass. 
		 * 
		 * <p>It may be that the method nodeHasMetaData in 
		 * class MetaDataTools is not determining if a node has metadata properly.</p>
		 */		
		[Test(description="ensure if method has at least one metadata that call to method hasMetaData returns the correct value")]
		public function check_hasMetaData_true():void {
			var methodXMLStr:String = "<method name=\"myMethod\" declaredBy=\"flex.lang.reflect.cases::MethodCase\" returnType=\"void\">" + 
									"<metadata name=\"Test\">" +
										"<arg key=\"description\" value=\"my description\"/>" +
									"</metadata>" +
								"</method>";
			var methodXML:XML = XML( methodXMLStr );
			
			method = new Method( methodXML );
			Assert.assertTrue( method.hasMetaData("Test") );
		} 

		/*
		* not sure how to test
		*/
		[Test(description="ensure that the proper metadata is pulled using getMetaData")]
		public function check_get_one_getMetaData():void {
			var methodXML:XML = <method name="myMethod" declaredBy="flex.lang.reflect.cases::MethodCase" returnType="void"> 
									<metadata name="Test">
										<arg key="description" value="my description"/>
									</metadata>
									<metadata name="Test">
										<arg key="description2" value="my description2"/>
									</metadata>
								</method>;
			
			method = new Method( methodXML );
			var metadata:String = method.getMetaData("Test", "description2");
			Assert.assertEquals( "my description2", metadata );
		}
		
		[Test(description="ensure returnType is retrieved properly")]
		public function check_get_returnType():void {
			// setup methodXML with a method that has a return type of String
			var methodXML:XML = <method name="myMethod" declaredBy="flex.lang.reflect.cases::MethodCase" returnType="String"> 
									<metadata name="Test">
										<arg key="description" value="my description"/>
									</metadata>
								</method>;
			
			method = new Method( methodXML );
			// get this method's return type
			var returnType:Class = method.returnType;
			// construct a temporary variable using the returnType class which should be String
			var testClass:String = new returnType();
			Assert.assertTrue( testClass is String );
		}
		
		[Test(description="ensure elementType is retrieved properly")]
		public function check_get_elementType():void {
			// setup methodXML containing metadata of type ArrayElementType 
			var methodXML:XML = <method name="createMethodXML" declaredBy="flex.lang.reflect.theories::MethodTheory" returnType="Array">
								  <metadata name="ArrayElementType">
								    <arg key="" value="Number"/>
								  </metadata>
								  <metadata name="DataPoints"/>
								</method>;
			
			method = new Method( methodXML );
			// get this method's element type
			var returnType:Class = method.elementType;
			// construct a temporary variable using the elementType class which should be ArrayElementType
			var testClass:* = new returnType();
			Assert.assertTrue( testClass is Number );
		}
	}
}