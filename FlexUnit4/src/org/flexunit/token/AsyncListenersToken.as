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

package org.flexunit.token {
	import org.flexunit.runner.IRunner;
	
	/**
	 * Responsible for indicating the status of <code>IAsyncRunListener</code>
	 */
	public class AsyncListenersToken {
		private var methodsEntries:Array;
		private var _error:Error;
		private var debugClassName:String;
		private var _token:AsyncTestToken;
		private var _runner:IRunner;
		
		/**
		 * Returns an instance of the <code>IRunner</code> associated with the AsyncListenersToken
		 */
		public function get runner():IRunner {
			return _runner;
		}
		
		public function set runner( value:IRunner ):void {
			_runner = value;	
		}
		
		/**
		 * Addes a notification method to an Array of notification methods
		 * 
		 * @param method The notification method to add
		 * 
		 * @return the current instance of the AsyncListenersToken
		 */
		public function addNotificationMethod( method:Function ):AsyncListenersToken {
			if (methodsEntries == null)
				methodsEntries = [];
	
			methodsEntries.push( method );			

			return this;
		}
		
		/**
		 * Calls each notification method and passes the current <code>IRunner</code> to that method
		 */
		public function sendReady():void {
			if ( methodsEntries ) {
 				for ( var i:int=0; i<methodsEntries.length; i++ ) {
					methodsEntries[ i ]( runner );
				}
 			}
		}
		
		/**
		 * Calls each notification method and passes the current <code>IRunner</code> to that method
		 */
		public function sendComplete():void {
			if ( methodsEntries ) {
 				for ( var i:int=0; i<methodsEntries.length; i++ ) {
					methodsEntries[ i ]( runner );
				}
 			}
		}
		
		/**
		 * Constructor.
		 */
		public function AsyncListenersToken() {
		}
	}
}
