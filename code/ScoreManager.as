package code
{
	import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.text.*;
	import flash.events.*;
	
	public class ScoreManager extends MovieClip
	{
		private var m_score:Number;
		private var m_timer:Timer;
		private var m_scoreBar:MovieClip;
		
		
		public function ScoreManager(scoreBar:MovieClip):void
		{
			m_scoreBar = scoreBar;
			m_score = 100;
			m_timer = new Timer(1000);
			m_timer.addEventListener(TimerEvent.TIMER, onTimerHandler);
			m_timer.stop();
		}
		
		public function startScore():void
		{
			m_timer.stop();
			m_score = 100;
			m_scoreBar.scaleX = 1;
			m_timer.delay = Config.scoreDelay;
			m_timer.start();
		}
		
		public function stopScore():void
		{
			m_timer.stop();
		}
		
		private function onTimerHandler(event:TimerEvent):void
		{
			m_score--;
			if (m_score < 0)
				MovieClip(root).gotoAndPlay(20);
			
			m_scoreBar.scaleX = m_score/100;
		}
	}
}