from dataclasses import dataclass, field
from typing import Dict, List, Optional, Any
from datetime import datetime

@dataclass
class Message:
    content: str
    is_user: bool
    timestamp: datetime = None
    attachments: List[Dict] = None
    
    def __post_init__(self):
        if self.timestamp is None:
            self.timestamp = datetime.now()
        if self.attachments is None:
            self.attachments = []
    
    def to_dict(self) -> Dict:
        return {
            "content": self.content,
            "is_user": self.is_user,
            "timestamp": self.timestamp.isoformat(),
            "attachments": self.attachments
        }

@dataclass
class ChatSession:
    user_id: str
    messages: List[Message] = field(default_factory=list)
    context: Dict[str, Any] = field(default_factory=dict)
    
    def add_message(self, message: Message) -> None:
        self.messages.append(message)
    
    def get_recent_messages(self, limit: int = 10) -> List[Message]:
        return self.messages[-limit:]
    
    def to_dict(self) -> Dict:
        return {
            "user_id": self.user_id,
            "messages": [msg.to_dict() for msg in self.messages],
            "context": self.context
        }
