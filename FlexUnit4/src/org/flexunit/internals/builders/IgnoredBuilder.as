/**
 * Copyright (c) 2009 Digital Primates IT Consulting Group
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 * 
 * @author     Michael Labriola 
 * @version    
 **/ 
package org.flexunit.internals.builders
{
	import flex.lang.reflect.Klass;
	
	import org.flexunit.runner.IRunner;
	import org.flexunit.runners.model.RunnerBuilderBase;
	
	/**
	 * Builds an <code>IgnoredClassRunner</code> for a test class.
	 */
	public class IgnoredBuilder extends RunnerBuilderBase {
		public static const IGNORE:String = "Ignore";
		
		/**
		 * Returns a <code>IgnoredClassRunner</code> if the class has an ["Ignore"] metadata tag.
		 * 
		 * @param testClass The class to check.
		 * 
		 * @return a <code>IgnoredClassRunner</code> if the class has an ["Ignore"] metadata tag; otherwise, a
		 * value of null is returned.
		 */
		override public function runnerForClass( testClass:Class ):IRunner {
			var klassInfo:Klass = new Klass( testClass );
			
			//If the klassInfo has ignore metadata, the test class should be ignored
			if ( klassInfo.hasMetaData( IGNORE ) ) {
				return new IgnoredClassRunner(testClass);
			}
			
			return null;
		}
	}
}