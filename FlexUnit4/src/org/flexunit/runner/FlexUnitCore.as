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
package org.flexunit.runner {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.*;
	
	import org.flexunit.IncludeFlexClasses;
	import org.flexunit.experimental.theories.Theories;
	import org.flexunit.runner.notification.Failure;
	import org.flexunit.runner.notification.IAsyncStartupRunListener;
	import org.flexunit.runner.notification.IRunListener;
	import org.flexunit.runner.notification.IRunNotifier;
	import org.flexunit.runner.notification.RunListener;
	import org.flexunit.runner.notification.RunNotifier;
	import org.flexunit.runner.notification.async.AsyncListenerWatcher;
	import org.flexunit.token.AsyncListenersToken;
	import org.flexunit.token.AsyncTestToken;
	import org.flexunit.token.ChildResult;
	import org.flexunit.utils.ClassNameUtil;

	/**  //TODO: Need to change version support to match supported FlexUnit versions and running instructions
	 * <code>FlexUnitCore</code> is a facade for running tests. It supports running JUnit 4 tests, 
	 * JUnit 3.8.x tests, and mixtures. To run tests from the command line, run 
	 * <code>java org.junit.runner.JUnitCore TestClass1 TestClass2 ...</code>.
	 * For one-shot test runs, use the static method <code> #runClasses(Class[])</code>. 
	 * If you want to add special listeners,
	 * create an instance of <code> org.junit.runner.JUnitCore</code> first and use it to run the tests.
	 * 
	 * @see org.flexunit.runner.Result
	 * @see org.flexunit.runner.notification.RunListener
	 * @see org.flexunit.runner.Request
	 */

	public class FlexUnitCore extends EventDispatcher {
		// We have a toggle in the compiler arguments so that we can choose whether or not the flex classes should
		// be compiled into the FlexUnit swc.  For actionscript only projects we do not want to compile the
		// flex classes since it will cause errors.
		CONFIG::useFlexClasses {
			// This class imports all Flex classes.
			private var t1:IncludeFlexClasses
		}
		
		private var notifier:IRunNotifier;
		private var asyncListenerWatcher:AsyncListenerWatcher;
		
		private static const RUN_LISTENER:String = "runListener";
		public static const TESTS_COMPLETE : String = "testsComplete";
		public static const RUNNER_START : String = "runnerStart";
		public static const RUNNER_COMPLETE : String = "runnerComplete";

		//Just keep theories linked in until we decide how to deal with it
		private var theory:Theories;

		public static function get version():String {
			return "4.0.0b2";
		}

		private function dealWithArgArray( ar:Array, foundClasses:Array, missingClasses:Array ):void {
			for ( var i:int=0; i<ar.length; i++ ) {
				try {
					if ( ar[ i ] is String ) {
						foundClasses.push( getDefinitionByName( ar[ i ] ) ); 
					} else if ( ar[ i ] is Array ) {
						dealWithArgArray( ar[ i ] as Array, foundClasses, missingClasses );
					} else if ( ar[ i ] is IRequest ) {
						foundClasses.push( ar[ i ] ); 
					} else if ( ar[ i ] is Class ) {
						foundClasses.push( ar[ i ] ); 
					} else if ( ar[ i ] is Object ) {
						//this is actually likely an instance.
						//eventually we intend to have more evolved support for
						//this, but, for right now, just try to make it a class
						var className:String = getQualifiedClassName( ar[ i ] );
						var definition:* = getDefinitionByName( className );
						foundClasses.push( definition );
					}
				}
				catch ( error:Error ) {
					//logger.error( "Cannot find class {0}", ar[i] ); 
					var desc:IDescription = Description.createSuiteDescription( ar[ i ] );
					var failure:Failure = new Failure( desc, error );
					missingClasses.push( failure );
				}
			}
		}

		/**
		 * Run all the tests contained in <code>args</code>.
		 * @param request the request describing tests
		 * @return a <code> Result</code> describing the details of the test run and the failed tests.
		 */
		public function run( ...args ):Result {
			var foundClasses:Array = new Array();
			//Unlike JUnit, missing classes is probably unlikely here, but lets preserve the metaphor
			//just in case
			var missingClasses:Array = new Array();
			
			dealWithArgArray( args, foundClasses, missingClasses );

			var result:Result = runClasses.apply( this, foundClasses );
			
			for ( var i:int=0; i<missingClasses.length; i++ ) {
				result.failures.push( missingClasses[ i ] );
			}
			
			return result;
		}

		/**  //TODO: No main to link to, what should be linked instead, if anything?
		 * Run the tests contained in <code>args</code>. Write feedback while the tests
		 * are running and write stack traces for all failed tests after all tests complete. This is
		 * similar to <code> #main(String[])</code>, but intended to be used programmatically.
		 * @param args The Array in which to find tests
		 */
		public function runClasses( ...args ):void {
			runRequest( Request.classes.apply( this, args ) );
		}
		
		/**  //TODO: No main to link to, what should be linked instead, if anything?
		 * Run the tests contained in <code>Request</code>. Write feedback while the tests
		 * are running and write stack traces for all failed tests after all tests complete. This is
		 * similar to <code> #main(String[])</code>, but intended to be used programmatically.
		 * @param request The Request describing the tests
		 */
		public function runRequest( request:Request ):void {
			runRunner( request.iRunner )
		}
		
		/**  //TODO: No main to link to, what should be linked instead, if anything?
		 * Run the tests contained in <code>IRunner</code>. Write feedback while the tests
		 * are running and write stack traces for all failed tests after all tests complete. This is
		 * similar to <code> #main(String[])</code>, but intended to be used programmatically.
		 * @param runner IRunner in which to find tests
		 */
		public function runRunner( runner:IRunner ):void {
			if ( asyncListenerWatcher.allListenersReady ) {
				beginRunnerExecution( runner );
			} else {
				//we need to wait until all listeners are ready (or failed) before we can continue
				var token:AsyncListenersToken = asyncListenerWatcher.startUpToken;
				token.runner = runner;
				token.addNotificationMethod( beginRunnerExecution );
			}
		}
		
		/**
		 * Starts the execution of the <code>IRunner</code>
		 */
		protected function beginRunnerExecution( runner:IRunner ):void {
			var result:Result = new Result();
			var runListener:RunListener = result.createListener();
			addFirstListener( runListener );

			var token:AsyncTestToken = new AsyncTestToken( ClassNameUtil.getLoggerFriendlyClassName( this ) );
			token.addNotificationMethod( handleRunnerComplete );
			token[ RUN_LISTENER ] = runListener;

			dispatchEvent( new Event( RUNNER_START ) );

			try {
				notifier.fireTestRunStarted( runner.description );
				runner.run( notifier, token );
			}
			
			catch ( error:Error ) {
				//I think we need to further restrict the case where this is true
				notifier.fireTestAssumptionFailed( new Failure( runner.description, error ) );

				finishRun( runListener );
			}
		}
		
		/**
		 * All tests have finished execution
		 */
		private function handleRunnerComplete( result:ChildResult ):void {
			var runListener:RunListener = result.token[ RUN_LISTENER ];

			finishRun( runListener );
		}

		private function finishRun( runListener:RunListener ):void {
			notifier.fireTestRunFinished( runListener.result );
			removeListener( runListener );
			
			dispatchEvent( new Event( TESTS_COMPLETE ) );
		}

		/**
		 * Add a listener to be notified as the tests run.
		 * @param listener the listener to add
		 * @see org.flexunit.runner.notification.RunListener
		 */
		public function addListener( listener:IRunListener ):void {
			notifier.addListener( listener );
			if ( listener is IAsyncStartupRunListener ) {
				asyncListenerWatcher.watchListener( listener as IAsyncStartupRunListener );
			}
		}

		private function addFirstListener( listener:IRunListener ):void {
			notifier.addFirstListener( listener );
			if ( listener is IAsyncStartupRunListener ) {
				asyncListenerWatcher.watchListener( listener as IAsyncStartupRunListener );
			}
		}

		/**
		 * Remove a listener.
		 * @param listener the listener to remove
		 */
		public function removeListener( listener:IRunListener ):void {
			notifier.removeListener( listener );

			if ( listener is IAsyncStartupRunListener ) {
				asyncListenerWatcher.unwatchListener( listener as IAsyncStartupRunListener );
			}			
		}
		
		protected function handleAllListenersReady( event:Event ):void {
			
		}
		
		/**
		 * Create a new <code>FlexUnitCore</code> to run tests.
		 */
		public function FlexUnitCore() {
			notifier = new RunNotifier();
			
			asyncListenerWatcher = new AsyncListenerWatcher( notifier, null );
			//asyncListenerWatcher.addEventListener( AsyncListenerWatcher.ALL_LISTENERS_READY, handleAllListenersReady, false, 0, true );
		}
	}
}