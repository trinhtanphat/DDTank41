package
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.net.URLRequest;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;

   public class CharacterSoundManager
   {

      private static const MusicFailedTryTime:int = 3;

      private static var _instance:CharacterSoundManager;

      public static var SITE_MAIN:String = "";


      private var currentMusicTry:int = 0;

      private var _dic:Dictionary;

      private var _music:Array;

      private var _allowSound:Boolean;

      private var _currentSound:Dictionary;

      private var _allowMusic:Boolean;

      private var _currentMusic:String;

      private var _musicLoop:Boolean;

      private var _isMusicPlaying:Boolean;

      private var _musicPlayList:Array;

      private var _musicVolume:Number = 100;

      private var soundVolumn:Number = 100;

      private var _musicSound:Sound;

      private var _musicChannel:SoundChannel;

      private var _musicPosition:Number = 0;

      public function CharacterSoundManager()
      {
         super();
         this._dic = new Dictionary();
         this._currentSound = new Dictionary(true);
         this._isMusicPlaying = false;
         this._musicLoop = false;
         this._allowMusic = true;
         this._allowSound = true;
         this._musicPlayList = [];
      }

      public static function get instance() : CharacterSoundManager
      {
         if(_instance == null)
         {
            _instance = new CharacterSoundManager();
         }
         return _instance;
      }

      public function get allowSound() : Boolean
      {
         return this._allowSound;
      }

      public function set allowSound(value:Boolean) : void
      {
         if(this._allowSound == value)
         {
            return;
         }
         this._allowSound = value;
         if(!this._allowSound)
         {
            this.stopAllSound();
         }
      }

      public function addSound(id:String, key:Class) : void
      {
         this._dic[id] = key;
      }

      public function get allowMusic() : Boolean
      {
         return this._allowMusic;
      }

      public function set allowMusic(value:Boolean) : void
      {
         if(this._allowMusic == value)
         {
            return;
         }
         this._allowMusic = value;
         if(this._allowMusic)
         {
            this.resumeMusic();
         }
         else
         {
            this.pauseMusic();
         }
      }

      public function onPlayStatus(e:*) : void
      {
         trace("-------------------------------");
         trace("------------Fuck---------------");
         trace("-------------------------------");
      }

      public function setup(music:Array, siteMain:String) : void
      {
         this._music = !!Boolean(music) ? music : [];
         SITE_MAIN = siteMain;
      }

      public function setConfig(allowMusic:Boolean, allowSound:Boolean, musicVolumn:Number, soundVolumn:Number) : void
      {
         this.allowMusic = allowMusic;
         this.allowSound = allowSound;
         this._musicVolume = musicVolumn;
         if(this.allowMusic && this._musicChannel)
         {
            this._musicChannel.soundTransform = new SoundTransform(musicVolumn / 100);
         }
         this.soundVolumn = soundVolumn;
      }

      public function setupAudioResource() : void
      {
         this.init();
      }

      private function init() : void
      {
      }

      public function checkHasSound(sound:String) : Boolean
      {
         if(this._dic[sound] != null)
         {
            return true;
         }
         return false;
      }

      public function play(id:String, allowMulti:Boolean = false, replaceSame:Boolean = true, loop:Number = 0) : void
      {
         var cls:Class = null;
         if(this._dic[id] == null)
         {
            try
            {
               cls = getDefinitionByName(id) as Class;
               this._dic[id] = cls;
            }
            catch(e:Error)
            {
               trace("sound not found: " + id);
               return;
            }
         }
         if(this._allowSound)
         {
            try
            {
               if(allowMulti || replaceSame || !this.isPlaying(id))
               {
                  this.playSoundImp(id,loop);
               }
            }
            catch(e:Error)
            {
            }
         }
      }

      public function playButtonSound() : void
      {
         this.play("008");
      }

      private function playSoundImp(id:String, loop:Number) : void
      {
         var ss:Sound = new this._dic[id]();
         var sc:SoundChannel = ss.play(0,loop,new SoundTransform(this.soundVolumn / 100));
         sc.addEventListener(Event.SOUND_COMPLETE,this.__soundComplete);
         this._currentSound[id] = sc;
      }

      private function __soundComplete(evt:Event) : void
      {
         var i:* = null;
         var c:SoundChannel = evt.currentTarget as SoundChannel;
         c.removeEventListener(Event.SOUND_COMPLETE,this.__soundComplete);
         c.stop();
         for(i in this._currentSound)
         {
            if(this._currentSound[i] == c)
            {
               this._currentSound[i] = null;
               return;
            }
         }
      }

      public function stop(s:String) : void
      {
         if(this._currentSound[s])
         {
            this._currentSound[s].stop();
            this._currentSound[s] = null;
         }
      }

      public function stopAllSound() : void
      {
         var sound:SoundChannel = null;
         for each(sound in this._currentSound)
         {
            if(sound)
            {
               sound.stop();
            }
         }
         this._currentSound = new Dictionary();
      }

      public function isPlaying(s:String) : Boolean
      {
         return this._currentSound[s] == null ? Boolean(Boolean(false)) : Boolean(Boolean(true));
      }

      public function playMusic(id:String, loops:Boolean = true, replaceSame:Boolean = false) : void
      {
         this.currentMusicTry = 0;
         if(replaceSame || this._currentMusic != id)
         {
            if(this._isMusicPlaying)
            {
               this.stopMusic();
            }
            this.playMusicImp([id],loops);
         }
      }

      private function playMusicImp(list:Array, loops:Boolean) : void
      {
         this._musicLoop = loops;
         this._musicPlayList = list.concat();
         if(list.length > 0)
         {
            this._currentMusic = String(list[0]);
            this._musicPosition = 0;
            this.startMusic();
         }
      }

      private function startMusic() : void
      {
         if(!this._currentMusic)
         {
            return;
         }
         this.stopMusicChannel();
         if(this._musicSound)
         {
            this._musicSound.removeEventListener(IOErrorEvent.IO_ERROR,this.__onMusicLoadError);
            try
            {
               this._musicSound.close();
            }
            catch(e:Error)
            {
            }
         }
         this._musicSound = new Sound();
         this._musicSound.addEventListener(IOErrorEvent.IO_ERROR,this.__onMusicLoadError);
         this._musicSound.load(new URLRequest(SITE_MAIN + "sound/" + this._currentMusic + ".mp3"));
         if(this._allowMusic)
         {
            this.startMusicChannel(this._musicPosition);
         }
         else
         {
            this._isMusicPlaying = false;
         }
      }

      private function startMusicChannel(position:Number) : void
      {
         var repeatCount:int = this._musicLoop ? 2147483647 : Math.max(0,this._musicPlayList.length - 1);
         this._musicChannel = this._musicSound.play(position,repeatCount,new SoundTransform(this._musicVolume / 100));
         if(this._musicChannel)
         {
            this._musicChannel.addEventListener(Event.SOUND_COMPLETE,this.__onMusicComplete);
            this._isMusicPlaying = true;
         }
      }

      private function stopMusicChannel() : void
      {
         if(this._musicChannel)
         {
            this._musicChannel.removeEventListener(Event.SOUND_COMPLETE,this.__onMusicComplete);
            this._musicChannel.stop();
            this._musicChannel = null;
         }
      }

      private function __onMusicLoadError(event:IOErrorEvent) : void
      {
         if(this._musicSound)
         {
            this._musicSound.removeEventListener(IOErrorEvent.IO_ERROR,this.__onMusicLoadError);
         }
         if(this.currentMusicTry < MusicFailedTryTime)
         {
            ++this.currentMusicTry;
            this._musicPosition = 0;
            this.startMusic();
         }
         else
         {
            this._isMusicPlaying = false;
         }
      }

      private function __onMusicComplete(event:Event) : void
      {
         this.stopMusicChannel();
         this._musicPosition = 0;
         this._isMusicPlaying = false;
      }

      public function setMusicVolumeByRatio(ratio:Number) : void
      {
         if(this.allowMusic)
         {
            this._musicVolume *= ratio;
            if(this._musicChannel)
            {
               this._musicChannel.soundTransform = new SoundTransform(this._musicVolume / 100);
            }
         }
      }

      public function pauseMusic() : void
      {
         if(this._isMusicPlaying && this._musicChannel)
         {
            this._musicPosition = this._musicChannel.position;
            this.stopMusicChannel();
            this._isMusicPlaying = false;
         }
      }

      public function resumeMusic() : void
      {
         if(this._allowMusic && this._currentMusic && !this._isMusicPlaying)
         {
            if(this._musicSound)
            {
               this.startMusicChannel(this._musicPosition);
            }
            else
            {
               this.startMusic();
            }
         }
      }

      public function stopMusic() : void
      {
         this.stopMusicChannel();
         if(this._musicSound)
         {
            this._musicSound.removeEventListener(IOErrorEvent.IO_ERROR,this.__onMusicLoadError);
            try
            {
               this._musicSound.close();
            }
            catch(e:Error)
            {
            }
            this._musicSound = null;
         }
         this._musicPosition = 0;
         this._isMusicPlaying = false;
         this._currentMusic = null;
      }

      public function playGameBackMusic(id:String) : void
      {
         this.playMusicImp([id,id],false);
      }

      public function onMetaData(info:Object) : void
      {
      }

      public function onXMPData(info:Object) : void
      {
      }

      public function onCuePoint(info:Object) : void
      {
      }
   }
}
