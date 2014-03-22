package code
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;

	public class Figure extends MovieClip
	{
		private var m_clip:DynamicMovie;

		private var m_wasMove:Boolean;
		private var m_wasSet:Boolean;

		private var m_resetX:Number;
		private var m_resetY:Number;

		private var m_totalRot:Number;
		private var m_rotIdx:Number;

		public var m_data:Array = new Array(Config.boardSize * Config.boardSize * 4);
		private var m_board:Board;


		public function Figure(board:Board):void
		{
			m_board = board;

			m_wasMove = false;
			m_wasSet = false;

			m_rotIdx = 0;
			m_totalRot = 0;

			for (var i:Number = 0; i < m_data.length; i++)
			{
				m_data[i] = 0;
			}

			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.addEventListener(MouseEvent.CLICK, onMouseClick);
		}

		public function stopFigure():void
		{
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.removeEventListener(MouseEvent.CLICK, onMouseClick);
		}

		public function addFigure(clip:DynamicMovie):void
		{
			m_clip = clip;
			addChild(m_clip);

			m_clip.setRegistration(Math.floor(m_clip.width/2), Math.floor(m_clip.height/2));
		}

		public function setFigurePos(xPos:Number, yPos:Number):void
		{
			m_clip.x2 = xPos;
			m_clip.y2 = yPos;

			m_resetX = m_clip.x2;
			m_resetY = m_clip.y2;
		}

		public function resetPos():void
		{
			clearFigure();

			m_clip.x2 = m_resetX;
			m_clip.y2 = m_resetY;
		}

		private function setFigure():void
		{
			// get upper-left point of figure
			var stageX:Number = Math.floor(m_clip.x2 - m_clip.width / 2);
			var stageY:Number = Math.floor(m_clip.y2 - m_clip.height / 2);

			var rc:Number = m_board.checkFigure(stageX,stageY,m_data.slice(Config.boardSize * Config.boardSize * m_rotIdx));
			if (rc == Board.E_OK)
			{
				m_board.setFigure(m_clip, stageX, stageY, m_data.slice(Config.boardSize*Config.boardSize*m_rotIdx));
				m_wasSet = true;
			}
			else if (rc == Board.E_BUSY)
			{
				m_clip.x2 = m_resetX;
				m_clip.y2 = m_resetY;
			}
			else
			{
				// workaround for upper-left corner of board
				if (stageX < m_board.x2 || stageY < m_board.y2)
				{
					m_clip.x2 = m_resetX;
					m_clip.y2 = m_resetY;
				}
				else
				{
					// user put figure out of board so save resetPos
					m_resetX = m_clip.x2;
					m_resetY = m_clip.y2;
				}
			}
		}

		private function clearFigure():void
		{
			if (m_wasSet)
			{
				// get upper-left point of figure
				var stageX:Number = Math.floor(m_clip.x2 - m_clip.width / 2);
				var stageY:Number = Math.floor(m_clip.y2 - m_clip.height / 2);

				m_board.clearFigure(stageX, stageY, m_data.slice(Config.boardSize*Config.boardSize*m_rotIdx));
				m_wasSet = false;
			}
		}

		private function onMouseDown(e:MouseEvent):void
		{
			clearFigure();
			m_clip.startDrag();

			this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}

		private function onMouseMove(e:MouseEvent):void
		{
			if (! m_wasMove)
			{
				// first move
				m_clip.alpha = 0.5;
				m_board.alpha2 = 0.7;
				m_board.removeChild(this);
				m_board.addChild(this);
			}
			m_wasMove = true;
		}

		public function onMouseUp(e:MouseEvent):void
		{
			m_clip.stopDrag();
			m_clip.alpha = 1;
			m_board.alpha2 = 1;
			setFigure();

			this.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			this.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}

		private function onMouseClick(e:MouseEvent):void
		{
			if (m_wasMove)
			{
				m_wasMove = false;
				return;
			}

			clearFigure();
			m_totalRot = 0;

			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			this.removeEventListener(MouseEvent.CLICK, onMouseClick);
		}

		public function rotateCWFigure():void
		{
			m_rotIdx++;
			if (m_rotIdx > 3)
			{
				m_rotIdx = 0;
			}
			m_clip.rotation2 = 90 * m_rotIdx;
		}

		private function onEnterFrame(e:Event):void
		{
			m_totalRot +=  30;
			m_clip.rotation2 +=  30;

			if (m_totalRot >= 90)
			{
				rotateCWFigure();
				setFigure();

				this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				this.addEventListener(MouseEvent.CLICK, onMouseClick);
			}
		}
	}
}