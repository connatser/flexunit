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
package org.flexunit.internals.runners.statements
{
	import org.flexunit.runners.model.FrameworkMethod;
	
	/**
	 * Sequences classes methods that have decorations.
	 * Example: "Before", "After", "BeforeClass", "AfterClass", ect.
	 */
	public class SequencerWithDecoration extends StatementSequencer
	{
		private var target:Object;	
		private var afters:Array;
		
		/**
		 * Creates an <code>InvokeMethod</code> object for the given method and test class
		 * 
		 * @param method The current method to execute
		 * @param test The test class
		 */
		protected function methodInvoker( method:FrameworkMethod, test:Object ):IAsyncStatement {
			return new InvokeMethod(method, test);
		}
		
		/**
		 * Determine if a potential <code>FrameworkMethod</code> is asynchronous
		 * 
		 * @param method The <code>FrameworkMethod</code> that the statement has wrapped
		 * @param test The current test class
		 * @param statement The current statement
		 * 
		 * @return An object that implements an <code>IAsyncStatement</code> that has been decorated with a potential async
		 */
		protected function withPotentialAsync( method:FrameworkMethod, test:Object, statement:IAsyncStatement ):IAsyncStatement {
			return statement;
		}
		
		/**
		 * Creats a object that implements an <code>IAsyncStatement</code> and decorates it
		 * 
		 * @param method The <code>FrameworkMethod</code> to wrap
		 * @param test The current test class
		 * 
		 * @return An object that implements an <code>IAsyncStatement</code> that has been decorated
		 */
		protected function withDecoration( method:FrameworkMethod, test:Object ):IAsyncStatement {
			var statement:IAsyncStatement = methodInvoker( method, test );
			statement = withPotentialAsync( method, test, statement );
			
			return statement;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function executeStep( child:* ):void {
			super.executeStep( child );

			var method:FrameworkMethod = child as FrameworkMethod;
			var statement:IAsyncStatement = withDecoration( method, target );

			try {
				statement.evaluate( myToken );
			} catch ( error:Error ) {
				errors.push( error );
			}
		}
		
		/**
		 * Constructor.
		 * 
		 * @param afters An array of potential statements that need to be executed at a specific time
		 * @target target The test class
		 */
		public function SequencerWithDecoration( afters:Array, target:Object ) {
			super( afters );
			this.target = target;
		}
	}
}