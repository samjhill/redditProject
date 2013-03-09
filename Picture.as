package  {
	
	import flash.display.MovieClip;
	import flash.utils.*;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.TextField;
	import fl.transitions.*;
	import fl.transitions.easing.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.net.FileReference; 
	import com.adobe.images.JPGEncoder;
	
	public class Picture extends MovieClip {
		
		var effects:String;
		var dominance:String;
		var dominantDimension:int;
		var stageDominantDimension:int;
		var tween:Tween;
		var transitionTime:int;
		var loader:Loader = new Loader();
		var originalWidth:int;
		var originalHeight:int;
		
		public function Picture(redditPost:Object, newX:int, newY:int, newEffects:String, newTransitionTime:int)
		{

			effects = newEffects;
			transitionTime = newTransitionTime;
			
			titleBox.text = redditPost.title;
			titleBox.scaleY = scaleX;
			titleBox.visible = false;
			
			loader.load(new URLRequest(redditPost.imageLink));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, showImage);
			
			
			function showImage(e:Event=null):void
			{
				this.width = loader.width;
				this.height = loader.height;
				titleBox.width = this.width;
				addChild(loader);
				setChildIndex(loader,0);
				// constructor code
				//this.width = loader.width;
				titleBox.x = loader.x + 2;
				titleBox.y = loader.y + 2;
				
				//drag
				addEventListener(MouseEvent.MOUSE_DOWN, drag);
				//drop
				addEventListener(MouseEvent.MOUSE_UP,drop);
				
				
				//stroke effect
				//http://krasimirtsonev.com/blog/article/adding-outline-border-of-text-or-movieclip-in-flash-with-as3
			    function addOutline(obj:*, color:uint, thickness:int = 2):void 
				{
    			var outline:GlowFilter = new GlowFilter();
    			outline.blurX = outline.blurY = thickness;
    			outline.color = color;
    			outline.quality = BitmapFilterQuality.HIGH;
    			outline.strength = 100;
				var dropShadow:DropShadowFilter = new DropShadowFilter();
    			var filterArray:Array = new Array();
    			filterArray.push(outline);
				filterArray.push(dropShadow);
   			    obj.filters = filterArray;
				}		
				addOutline(titleBox,0, 2);
				addOutline(loader,99999999,5);
				
				
				loader.scaleX = loader.scaleY;
				
				
				if ((stage.stageHeight / stage.stageWidth) < (this.height / this.width))
						{
							//this is a y-dominant picture
							dominance="y";
							dominantDimension=loader.height;
							stageDominantDimension = stage.stageWidth;
            			}
						else 
						{
							dominance="x";
							dominantDimension=loader.width;
							stageDominantDimension = stage.stageHeight;
            			}
				
				
				if(stage.stageHeight < loader.height)
				{
					//scale the picture down, it's too bag dammit
					loader.height = stage.stageHeight *(3/5);
					loader.scaleX = loader.scaleY;
				}
				
				if(effects=="fade")
				{
					try
					{
							
						//tween alpha in
						var tweenPicAlpha:Tween = new Tween(loader, "alpha", Regular.easeOut, 0, 1, 1, true);
						var tweenTextAlpha:Tween = new Tween(titleBox, "alpha",Regular.easeOut, 0, 1, 1, true);
						
						//move around the picture
						var tween = new Tween(loader, dominance, None.easeOut, 0, -(stageDominantDimension-(dominantDimension/4)) , (transitionTime/1000)-2,true);
													 //x or y						//auto width or height
													
						var tweenText = new Tween(titleBox, dominance,  None.easeOut, 0, -(stageDominantDimension-(dominantDimension/4)) , (transitionTime/1000)-2,true);
						tween.addEventListener(TweenEvent.MOTION_FINISH, onFinish);
						
						//fade the picture out as we finish
						function onFinish(e:TweenEvent):void 
						{
							trace("Finished tween");
							var tweenBack:Tween = new Tween(loader, "alpha", Regular.easeOut, 1, 0, 1, true);
							var tweenTextBack:Tween = new Tween(titleBox, "alpha", Regular.easeOut, 1, 0, 1, true);
	
						}
					
					}
					catch (e:Error) 
					{
						trace(e);
					}
				}
				if(effects=="pile")
				{
					//loader.width = stage.stageWidth / MovieClip(root).redditPlaylist.length;
					//loader.x = stage.stageWidth*.5 - loader.width*.5;
					//loader.y = stage.stageHeight*.5 - loader.height*.5;
					//titleBox.x = loader.x;
					//titleBox.y = loader.y;
					originalWidth = loader.width;
					originalHeight = loader.height;
					loader.width = 100;
					loader.height = 100;
					loader.x = newX;
					loader.y = newY;
					
					
				}
				if(effects=="slideshow")
				{
					loader.y = stage.stageWidth*.5 - loader.width*.5;
					loader.alpha = .98;
					loader.x = newX;
					loader.y= newY;
					titleBox.x = loader.x;
					titleBox.y = loader.y;
					
					var ssTween = new Tween(loader, "x", None.easeOut, loader.x, -5000, transitionTime,false);
											     //x or y						//auto width or height
												
					var ssTweenText = new Tween(titleBox, "x",  None.easeOut, titleBox.x, -5000, transitionTime,false);
					
				}
				else  // no effects chosen
				{
					loader.alpha = 1;
				}
				
				
		}
		
	}

	
	public function drag(e:Event):void
	{
		//bring picture to front
		MovieClip(root).setChildIndex(this, parent.numChildren-1);
		//bring upvote to front - 2
		MovieClip(root).setChildIndex(MovieClip(root).upvote, parent.numChildren-2);
		//bring downvote to front - 3
		MovieClip(root).setChildIndex(MovieClip(root).downvote, parent.numChildren-3);
		startDrag();
		
	}
	
	public function drop(e:MouseEvent):void
	{
		stopDrag();
		//dropped on upvote
		try{
			if(this.dropTarget.name == "instance8" || this.y <= -100) 
			{
				trace("Dropped on the green target.");
				trace(loader.content);
				//
				//save the file to disk 
				var bitmapData:BitmapData=new BitmapData(loader.width, loader.height);
				bitmapData.draw(loader);  
				//
				var jpgEncoder:JPGEncoder = new JPGEncoder(100);
				var byteArray:ByteArray = jpgEncoder.encode(bitmapData);
				var fileReference:FileReference=new FileReference();
				var r:RegExp = new RegExp(/[^a-zA-Z 0-9]+/g) ;
				var string:String = titleBox.text.replace(r, "");
				fileReference.save(byteArray, (string+ ".jpg"));
				fileReference.addEventListener(Event.COMPLETE, destroyMe);
			}
			
			//dropped on downvote
			if(this.dropTarget.name == "instance1" || this.y >= 300) 
			{
				trace("Deleted " + this);
				MovieClip(root).poofCloud.alpha = 1;
				MovieClip(root).poofCloud.x = stage.stageWidth/2;
				MovieClip(root).poofCloud.y = 699.3;
				var tweenBack:Tween = new Tween(MovieClip(root).poofCloud, "alpha", Regular.easeOut, 2, 0, 1, true);
				destroyMe();
			}
		}
		catch(e:Error)
		{
			trace(e);
		}
		
		//only resizes the picture if it has not yet been resized
		if(loader.width != originalWidth)
		{
			titleBox.visible = true;
			titleBox.x = loader.x;
			titleBox.y = loader.y;
			//var hoverGrowX:Tween = new Tween(loader, "width", Regular.easeOut, this.width, originalWidth, 1, true);
			//var hoverGrowY:Tween = new Tween(loader, "height", Regular.easeOut, this.height, originalHeight, 1, true);
			loader.width = originalWidth;
			loader.height = originalHeight;
			
			this.addEventListener(MouseEvent.MOUSE_UP, closeMe);
			function closeMe(e:MouseEvent):void
			{
				titleBox.visible = false;
				var hoverShrinkX:Tween = new Tween(loader, "width", Regular.easeOut, originalWidth, 100, 1, true);
				var hoverShrinkY:Tween = new Tween(loader, "height", Regular.easeOut, originalHeight, 100, 1, true);
			}
		}
		
	}
	
	function destroyMe(e:Event=null):void 
	{
        var parent:DisplayObjectContainer = this.parent;
        parent.removeChild(this);
	
	}
}}
