// Sam Hill
// Project 3
// Redit image downloader

// tutorials used
// http://blogs.adobe.com/pdehaan/2006/07/using_the_timer_class_in_actio.html
// http://www.kirupa.com/developer/flashcs3/using_xml_as3_pg3.htm
// http://www.fladev.com/featured/building-a-fullscreen-background-image-with-as3/
// http://www.republicofcode.com/tutorials/flash/as3keyboard/
// and a healthy dose of adobe API
// 
// to be addressed:
// [x]drag pictures upward to save them
// [x]slider to control transition time
// [x] resize window and tween background must be put in separate functions
// [x]if a subreddit returns no images, display ('no images found at that subreddit') or similar
// [x]slide-out control panel with all settings
// loading symbols
// [x] make ui 'stick' to the right side of the window when resized
// [x] scroll through the WHOLE picture
// arrow controls cut off the Tween from stopping, so image gets screwed up


package  {
	import com.adobe.images.JPGEncoder;
	import flash.utils.*;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.TextField;
	import fl.transitions.*;
	import fl.transitions.easing.*;
	
	
	public class reddit extends MovieClip {
		var startX:int = 0;
		var startY:int = stage.stageHeight*(1/3);
		public var effectsType:String = "none";
		
		var bg:int = 0; //bg is used to determine which background index to use
		// time is in milliseconds
		public var transitionTime:int = 30000;
		var tag:String = "funny";
		var redditRequest:URLRequest = new URLRequest("http://www.reddit.com/r/" + tag + "/.rss");
		
		//the URLRequest contains the path to our XML
		var redditLoader:URLLoader = new URLLoader();
		var redditdata:XML = new XML();
		var redditPlaylist:Array = new Array();
		var activeImages:Array = new Array();
		//image loader
		var loader:Loader = new Loader();
			
		// dominant dimension is used later to calculate which direction I want the picture to move
		var dominance:String;
		var dominantDimension:int;
		var stageDominantDimension:int;
		var tween:Tween;
		
		public function reddit()
		{
			//control panel
			controlPanel.settingsOpenClose.addEventListener(MouseEvent.MOUSE_DOWN, openControlPanel);
			controlPanel.settingsOpenClose.addEventListener(MouseEvent.MOUSE_DOWN, closeControlPanel);
			var isOpen:Boolean = false;
			
			function openControlPanel(e:MouseEvent):void
			{
				if(isOpen == false)
				{
					var CPtween:Tween = new Tween(controlPanel,"x",Regular.easeIn, controlPanel.x, controlPanel.x - 341 , 1, true);
					CPtween.addEventListener(TweenEvent.MOTION_FINISH, onFinish);
					function onFinish(e:Event = null):void
					{
						isOpen = true;
					}
				}
			}
			function closeControlPanel(e:MouseEvent):void
			{
				if(isOpen == true)
				{
					var CPtweenBack:Tween = new Tween(controlPanel,"x",Regular.easeIn, controlPanel.x, controlPanel.x + 341, 1, true);
					CPtweenBack.addEventListener(TweenEvent.MOTION_FINISH, onFinish);
					function onFinish(e:Event = null):void
					{
						isOpen = false;
					}
				}
			}
			//clear subreddit input text when clicked
			controlPanel.subredditBox.addEventListener( FocusEvent.FOCUS_IN, clearText );
			function clearText(e:Event):void
			{
				controlPanel.subredditBox.text="";
			}
			//when someone presses a key, check what they want to do
			stage.addEventListener(KeyboardEvent.KEY_DOWN, routeKeyboardInput);
			function routeKeyboardInput(e:KeyboardEvent):void
			{
				if (e.keyCode == 13) //enter
				{
					changeSubreddit(e);
				}
				if (e.keyCode == 37)//left arrow
				{
					//do something
					bg = bg-2;
					tween.fforward();
					//changeBackground();
				}
				if (e.keyCode == 39)//right arrow
				{
					//do something interesting
					bg = bg + 1;
					tween.fforward();
					//changeBackground();
				}
			}
			
			redditLoader.load(redditRequest);
			redditLoader.addEventListener(Event.COMPLETE, LoadXML);
			
			
			//close docs when it's clicked
			docs.addEventListener(MouseEvent.MOUSE_DOWN, closeIt);
			function closeIt(e:Event):void
			{
				docs.visible=false;
			}
			
			//stage stuff
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, stageResize);
			
			
		}
		
		public function makePictures(e:Event=null):void
		{
			var defaultY:int = 100;
			var defaultX:int = 50;
			var desiredX:int = defaultX;
			var desiredY:int = defaultY;
			
			var border:int = 120; //border width in pixels
			trace("Playlist length: " + redditPlaylist.length);
			for (var index:int=0; index < redditPlaylist.length; index++)
			{
				//
				//effect choice here
				//
				//var effects:String = effectsType;
				var effects:String = "pile";
				var picture:Picture = new Picture(redditPlaylist[index],desiredX,desiredY,effects,transitionTime);
				
				activeImages.push(picture);
				addChildAt(activeImages[index],0);
				desiredY = desiredY + border;
				if(desiredY >= 625)
				{
					desiredX = desiredX + border;
					desiredY = defaultY;
				}
			}
			
			
		}
		
		public function changeSubreddit(e:KeyboardEvent):void
		{
			setChildIndex(controlPanel, (numChildren-1));
			setChildIndex(upvote, (numChildren-2));
			setChildIndex(poofCloud, (numChildren-3));
			setChildIndex(downvote, (numChildren-4));
			var uiStuff:Array = new Array();
			uiStuff.push(controlPanel);
			uiStuff.push(upvote);
			uiStuff.push(poofCloud);
			uiStuff.push(downvote);
			
			//wipe out old pictures
			for(var index:int = 0; index < activeImages.length; index++)
			{
				try{
					removeChild(activeImages[index]);
				}
				catch(e:Error)
				{
					trace(e);
				}
				
			}
			//repopulate the stage
			for(var i:int = 0; i < uiStuff.length; i++)
			{
				addChild(uiStuff.pop());
			}
			
			var redditRequest:URLRequest = new URLRequest("http://www.reddit.com/r/" + controlPanel.subredditBox.text + "/.rss?limit=100");
			trace("Changing subreddit to " + controlPanel.subredditBox.text);
			
			//let's clear the array here so we get fresh images
			redditPlaylist.length = 0; 
			activeImages.length = 0;
			redditLoader.load(redditRequest);
			redditLoader.addEventListener(Event.COMPLETE, LoadXML);
		}
		
		public function stageResize(e:Event=null):void
		{
			//move UI components with the right side of the window
			upvote.x = stage.stageWidth/2;
			downvote.x = stage.stageWidth/2;
			downvote.y = stage.stageHeight*(7/8);
			controlPanel.x = 964.95; // reset x pos of control panel
			controlPanel.x = stage.stageWidth - controlPanel.width*(1/5);
			controlPanel.y = stage.stageHeight/2;
			stage.align = StageAlign.TOP_LEFT;
		}
		
	
		function LoadXML(e:Event):void
		{
			redditdata = new XML(e.target.data);
			xmlLoaded(redditdata);
		}
		
		function xmlLoaded(xmlInput):void
		{
			var entries:XMLList = xmlInput.channel.children();
			//trace(entries);
			for each (var entry:XML in entries)
			{
				
				var tempEntry:Object = new Object();
				
				tempEntry.title = entry.title.text();
				tempEntry.link = entry.link.text();
				tempEntry.description = entry.description.text();
				
				//proccess the link a bit
				//here comes imgur
				var startPosition:int = -1;
				var endPosition:int = -1;
				startPosition = entry.description.toString().indexOf("http://i.imgur.com/");
				endPosition = startPosition + 24;
				
				//trace(startPosition);
				if(startPosition != -1)
				{
					//parse the link, store it in the tempEntry
					var link:String = entry.description.toString().substring(startPosition, endPosition);
					tempEntry.imageLink = link;
					
					
					//write the entry to the playlist array
					//if it doesn't have an image link, we don't want it
					redditPlaylist.push(tempEntry);
				}
				
				
				
			}
			
			trace("Gathered " + redditPlaylist.length + " images.");
			makePictures();
			if(redditPlaylist.length <= 1)
			{
				controlPanel.subredditBox.text = ("No valid images found at that subreddit.");
			}
			
		}}}