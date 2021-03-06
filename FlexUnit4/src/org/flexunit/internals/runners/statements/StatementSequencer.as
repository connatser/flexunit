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
package org.flexunit.internals.runners.statements {
	import flash.utils.*;
	
	import org.flexunit.internals.runners.model.MultipleFailureException;
	import org.flexunit.token.AsyncTestToken;
	import org.flexunit.token.ChildResult;
	import org.flexunit.utils.ClassNameUtil;
	
	/**
	 * Sequences statments that are to be executed
	 */
	public class StatementSequencer extends AsyncStatementBase implements IAsyncStatement {
		protected var queue:Array;
		protected var errors:Array;
		
		/**
		 * Constructor.
		 * 
		 * @param queue An <code>Array</code> containing object that implement <code>IAsyncStatment</code>
		 */
		public function StatementSequencer( queue:Array=null ) {
			super();
			
			if (!queue) {
				queue = new Array();
			}			
			
			//Copy the queue
			this.queue = queue.slice();
			this.errors = new Array();		
			
			//Create a new token that will track the execution of this statement seqeuence
			myToken = new AsyncTestToken( ClassNameUtil.getLoggerFriendlyClassName( this ) );
			myToken.addNotificationMethod( handleChildExecuteComplete );
		}
		
		/**
		 * Adds an object that implements <code>IAsyncStatement</code> to the queue of statments to execute
		 * 
		 * @param child The object that implements <code>IAsyncStatement</code> to add
		 */
		public function addStep( child:IAsyncStatement ):void {
			if ( child ) {
				queue.push( child );
			}
		}
		
		/**
		 * Evaluates the child
		 * 
		 * @param child The child object to be evaluated
		 */
		protected function executeStep( child:* ):void {
			if ( child is IAsyncStatement ) {
				IAsyncStatement( child ).evaluate( myToken );
			}
		}
		
		/**
		 * Starts evaluating the queue of statements
		 * 
		 * @param parentToken The token to be notified when the statements have finished running
		 */
		public function evaluate( parentToken:AsyncTestToken ):void {
			this.parentToken = parentToken;
			handleChildExecuteComplete( null );
		}
		
		/**
		 * Executes the first step in the sequence
		 * 
		 * @param parentToken The token to be notified when the setp has finished running
		 */
		public function handleChildExecuteComplete( result:ChildResult ):void {
			var step:*;
			
			if ( result && result.error ) {
				errors.push( result.error );
			}
			
			if ( queue.length > 0 ) {
				step = queue.shift();	
				
				//trace("Sequence Executing Next Step " + step  );
				executeStep( step );
				//trace("Sequence Done Executing Step " + step );
			} else {
				//trace("Sequence Sending Complete " + this );
				sendComplete(); 
			}
		}

		/**
		 * Queues errors and sends them, either using MultipleFailureException
		 * or the super sendComplete, if there is only one error in the queue. 
		 * 
		 * @param error The Error to send
		 * @inheritDoc
		 */
		override protected function sendComplete( error:Error=null ):void {
			var sendError:Error;
			
			//Determine if any errors were passed to this method
			if ( error ) {
				errors.push( error );
			}
			
			//Determine whether to send a single error or MultipleFailureException containing the array of errors
			if (errors.length == 1)
				sendError = errors[ 0 ];
			else if ( errors.length > 1 ) {
				sendError = new MultipleFailureException(errors);
			}

			super.sendComplete( sendError );
		}

		/**
		 * Returns the current queue of statements that are in the sequence. 
		 * @return A string representing the sequence queue.
		 * 
		 */
		override public function toString():String {
			var sequenceString:String = "StatementSequencer :\n";
			
			if ( queue ) {
				for ( var i:int=0; i<queue.length; i++ ) {
					sequenceString += ( "   " + i + " : " + queue[ i ].toString() + "\n" );
				}
			}
			
			return sequenceString;
		}
	}
}