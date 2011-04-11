package org.osflash.signals
{
	import asunit.asserts.*;
	import asunit.framework.IAsync;

	public class DeluxeSignalTest
	{	
	    [Inject]
	    public var async:IAsync;
	    
		private var completed:DeluxeSignal;
		
		[Before]
		public function setUp():void
		{
			completed = new DeluxeSignal(this);
		}
		
		[After]
		public function tearDown():void
		{
			completed.removeAll();
			completed = null;
		}

		[Test]
		public function add_listener_then_remove_function_not_in_listeners_should_do_nothing():void
		{
			completed.add(newEmptyHandler());
			completed.remove(newEmptyHandler());
			assertEquals(1, completed.numListeners);
		}
		
		private function newEmptyHandler():Function
		{
			return function():void {};
		}
		
		//////
		
		[Test]
		public function strict_should_be_true() : void
		{
			assertTrue('strict should be true', completed.strict);
		}
		
		//////
		
		[Test]
		public function verify_strict_after_setting_it_to_false() : void
		{
			completed.strict = false;
			
			assertFalse('strict should be false', completed.strict);
		}
		
		//////
		
		[Test]
		public function verify_strict_is_true_after_dispatch() : void
		{
			completed.add(newEmptyHandler());
			completed.dispatch();
			
			assertTrue('strict should be true', completed.strict);
		}
		
		//////
		
		[Test]
		public function set_strict_to_false_and_verify_strict_is_false_after_dispatch() : void
		{
			completed.strict = false;
			
			completed.add(newEmptyHandler());
			completed.dispatch();
			
			assertFalse('strict should be false', completed.strict);
		}
		
		
		//////
		[Test]
		public function dispatch_2_listeners_1st_listener_removes_itself_then_2nd_listener_is_still_called():void
		{
			completed.add(selfRemover);
			// async.add verifies the second listener is called
			completed.add(async.add(newEmptyHandler(), 10));
			completed.dispatch();
		}
		
		private function selfRemover():void
		{
			completed.remove(selfRemover);
		}
		//////
		[Test]
		public function dispatch_2_listeners_1st_listener_removes_all_then_2nd_listener_is_still_called():void
		{
			completed.add(async.add(allRemover, 10));
			completed.add(async.add(newEmptyHandler(), 10));
			completed.dispatch();
		}
		
		private function allRemover():void
		{
			completed.removeAll();
		}
		//////
		[Test]
		public function adding_a_listener_during_dispatch_should_not_call_it():void
		{
			completed.add(async.add(addListenerDuringDispatch, 10));
			completed.dispatch();
		}
		
		private function addListenerDuringDispatch():void
		{
			completed.add(failIfCalled);
		}
		
		private function failIfCalled():void
		{
			fail("This listener should not be called.");
		}
		
		
		//////
		[Test]
		public function can_use_anonymous_listeners():void
		{
			var bindings:Array = [];
			
			for ( var i:int = 0; i < 100;  i++ )
			{
				bindings.push(completed.add(function():void{}));
			}
			
			assertEquals("there should be 100 listeners", 100, completed.numListeners);
			
			for each( var binding:ISignalBinding in bindings )
			{
				completed.remove(binding.listener);
			}

			assertEquals("all anonymous listeners removed", 0, completed.numListeners);
		}
		
		//////
		[Test]
		public function can_use_anonymous_listeners_in_addOnce():void
		{
			var bindings:Array = [];
			
			for ( var i:int = 0; i < 100;  i++ )
			{
				bindings.push(completed.addOnce(function():void{}));
			}
			
			assertEquals("there should be 100 listeners", 100, completed.numListeners);
			
			for each( var binding:ISignalBinding in bindings )
			{
				completed.remove(binding.listener);
			}

			assertEquals("all anonymous listeners removed", 0, completed.numListeners);
		}
		
		//////
		
		[Test]
		public function removed_listener_should_return_binding():void
		{
			var listener:Function = function():void{};
			var binding:ISignalBinding = completed.add(listener);
			
			assertTrue("Binding is returned", binding == completed.remove(listener));
		}
		
		//////
		
		[Test]
		public function removed_listener_should_be_returned():void
		{
			var binding:ISignalBinding = completed.add(function():void{});
			var listener:Function = binding.listener;
			
			assertTrue("Binding is returned", binding == completed.remove(listener));
		}
	}
}
