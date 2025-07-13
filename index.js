// index.js
require('dotenv').config();
const express = require('express');
const { IgApiClient } = require('instagram-private-api');
const fs = require('fs');
const bodyParser = require('body-parser');
const cors = require('cors');

const ig = new IgApiClient();
const app = express();
app.use(bodyParser.json());
app.use(cors());

const SESSION_FILE = './session.json';
const username = process.env.INSTAGRAM_USERNAME;
const password = process.env.INSTAGRAM_PASSWORD;

if (!username || !password) {
  console.error('❌ Please set INSTAGRAM_USERNAME and INSTAGRAM_PASSWORD in your .env file');
  process.exit(1);
}

ig.state.generateDevice(username);

async function login() {
  if (fs.existsSync(SESSION_FILE)) {
    const saved = JSON.parse(fs.readFileSync(SESSION_FILE, 'utf8'));
    await ig.state.deserialize(saved);
    console.log('✅ Logged in with saved session');
  } else {
    await ig.account.login(username, password);
    const serialized = await ig.state.serialize();
    delete serialized.constants; // optional cleanup
    fs.writeFileSync(SESSION_FILE, JSON.stringify(serialized));
    console.log('🔐 Logged in and session saved');
  }
}

app.get('/inbox', async (req, res) => {
  try {
    const inboxFeed = ig.feed.directInbox();
    const threads = await inboxFeed.items();
    const mapped = threads.map(t => ({
      id: t.thread_id,
      title: t.users.length === 1 ? t.users[0].username : `${t.users[0].username} + ${t.users.length - 1}`,
      usernames: t.users.map(u => u.username),
      lastMessage: t.items[0]?.text || getMessageTypeDisplay(t.items[0]),
      timestamp: t.items[0]?.timestamp,
      unreadCount: t.has_newer ? 1 : 0, // Simplified for watch
      isGroup: t.users.length > 1
    }));
    res.json(mapped);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Helper function for watch-friendly message type display
function getMessageTypeDisplay(item) {
  if (!item) return '[Empty]';
  
  switch (item.item_type) {
    case 'media': return '📷 Photo';
    case 'voice_media': return '🎵 Voice';
    case 'raven_media': return '👻 Disappearing';
    case 'link': return '🔗 Link';
    case 'like': return '❤️';
    case 'action_log': return '📝 Action';
    default: return item.text || `[${item.item_type}]`;
  }
}

app.get('/thread/:id', async (req, res) => {
  try {
    const limit = req.query.limit ? parseInt(req.query.limit) : 20; // Default 20 messages
    const threadFeed = ig.feed.directThread({ thread_id: req.params.id });
    
    let allMessages = [];
    let items = await threadFeed.items();
    allMessages = allMessages.concat(items);
    
    // If user wants more messages and there are more available, keep fetching
    while (allMessages.length < limit && threadFeed.isMoreAvailable()) {
      items = await threadFeed.items();
      allMessages = allMessages.concat(items);
    }
    
    // Limit to requested number
    const limitedMessages = allMessages.slice(0, limit);
    
    // Get thread users from inbox (more efficient)
    const inboxFeed = ig.feed.directInbox();
    const threads = await inboxFeed.items();
    const currentThread = threads.find(t => t.thread_id === req.params.id);
    const threadUsers = currentThread ? currentThread.users : [];
    
    // If thread not found in inbox, fallback to extracting users from messages
    if (threadUsers.length === 0) {
      const userIds = [...new Set(limitedMessages.map(msg => msg.user_id))];
      
      for (const userId of userIds) {
        try {
          const userInfo = await ig.user.info(userId);
          threadUsers.push({
            pk: userInfo.pk,
            username: userInfo.username,
            full_name: userInfo.full_name,
            profile_pic_url: userInfo.profile_pic_url
          });
        } catch (err) {
          console.warn(`Could not fetch user info for ${userId}:`, err.message);
          threadUsers.push({
            pk: userId,
            username: 'Unknown User',
            full_name: 'Unknown User',
            profile_pic_url: null
          });
        }
      }
    }
    
    const messages = limitedMessages.map(msg => {
      // Find sender info from thread users
      const sender = threadUsers.find(u => u.pk === msg.user_id);
      const senderName = sender ? sender.username : 'Unknown User';
      
      const baseMessage = {
        id: msg.item_id,
        user: msg.user_id,
        timestamp: msg.timestamp,
        type: msg.item_type,
        senderName: senderName,
        senderUsername: sender ? sender.username : null,
        senderProfilePic: sender ? sender.profile_pic_url : null
      };

      // Apple Watch optimized message handling
      switch (msg.item_type) {
        case 'text':
          return {
            ...baseMessage,
            text: msg.text,
            displayText: msg.text.length > 100 ? msg.text.substring(0, 97) + '...' : msg.text,
            contentType: 'text',
            icon: '💬'
          };
        
        case 'media':
          const mediaType = msg.media?.media_type === 1 ? 'photo' : 'video';
          return {
            ...baseMessage,
            text: msg.text || `[${mediaType}]`,
            displayText: msg.text ? (msg.text.length > 80 ? msg.text.substring(0, 77) + '...' : msg.text) : `📷 ${mediaType}`,
            contentType: 'media',
            mediaType: mediaType,
            icon: mediaType === 'photo' ? '📷' : '🎬',
            hasMedia: true
          };
        
        case 'voice_media':
          return {
            ...baseMessage,
            text: '[Voice Message]',
            displayText: `🎵 Voice (${Math.round(msg.voice_media?.duration || 0)}s)`,
            contentType: 'voice',
            duration: msg.voice_media?.duration || 0,
            icon: '🎵'
          };
        
        case 'raven_media':
          return {
            ...baseMessage,
            text: '[Disappearing Photo/Video]',
            displayText: '👻 Disappearing',
            contentType: 'disappearing',
            icon: '👻'
          };
        
        case 'link':
          return {
            ...baseMessage,
            text: msg.text || '[Link]',
            displayText: msg.text ? (msg.text.length > 80 ? msg.text.substring(0, 77) + '...' : msg.text) : '🔗 Link',
            contentType: 'link',
            linkTitle: msg.link?.link_context?.link_title,
            icon: '🔗'
          };
        
        case 'like':
          return {
            ...baseMessage,
            text: '[❤️ Like]',
            displayText: '❤️',
            contentType: 'like',
            icon: '❤️'
          };
        
        case 'action_log':
          return {
            ...baseMessage,
            text: msg.action_log?.description || '[Action]',
            displayText: '📝 ' + (msg.action_log?.description?.substring(0, 50) || 'Action'),
            contentType: 'action',
            icon: '📝'
          };
        
        default:
          return {
            ...baseMessage,
            text: msg.text || `[${msg.item_type}]`,
            displayText: msg.text || `❓ ${msg.item_type}`,
            contentType: 'unknown',
            icon: '❓'
          };
      }
    });
    
    res.json({
      messages,
      total: messages.length,
      hasMore: threadFeed.isMoreAvailable(),
      requestedLimit: limit,
      threadInfo: {
        id: req.params.id,
        title: currentThread?.thread_title || (threadUsers.length > 1 ? `Group Chat (${threadUsers.length} users)` : threadUsers[0]?.username || 'Chat'),
        users: threadUsers.map(u => ({
          id: u.pk,
          username: u.username,
          fullName: u.full_name,
          profilePic: u.profile_pic_url
        })),
        isGroup: threadUsers.length > 1
      }
    });
  } catch (err) {
    console.error('Thread fetch error:', err);
    res.status(500).json({ error: err.message });
  }
});

app.post('/thread/:id/send', async (req, res) => {
  try {
    const { message } = req.body;
    await ig.entity.directThread(req.params.id).broadcastText(message);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Apple Watch optimized endpoints

// Get thread summary for watch (minimal data)
app.get('/watch/thread/:id/summary', async (req, res) => {
  try {
    const threadFeed = ig.feed.directThread({ thread_id: req.params.id });
    const items = await threadFeed.items();
    
    const recentMessages = items.slice(0, 5).map(msg => ({
      id: msg.item_id,
      displayText: getMessageDisplayText(msg),
      icon: getMessageIcon(msg.item_type),
      timestamp: msg.timestamp,
      isFromMe: msg.user_id === ig.state.cookieUserId
    }));
    
    res.json({
      threadId: req.params.id,
      messageCount: items.length,
      recentMessages,
      hasMore: threadFeed.isMoreAvailable()
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Quick reply with predefined messages
app.post('/watch/thread/:id/quick-reply', async (req, res) => {
  try {
    const { replyType } = req.body;
    
    const quickReplies = {
      'thumbs_up': '👍',
      'ok': 'Ok',
      'thanks': 'Thanks!',
      'yes': 'Yes',
      'no': 'No',
      'busy': 'Busy right now, talk later',
      'heart': '❤️'
    };
    
    const message = quickReplies[replyType] || replyType;
    await ig.entity.directThread(req.params.id).broadcastText(message);
    res.json({ success: true, sentMessage: message });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get unread count for watch complication
app.get('/watch/unread-count', async (req, res) => {
  try {
    const inboxFeed = ig.feed.directInbox();
    const threads = await inboxFeed.items();
    const unreadCount = threads.filter(t => t.has_newer).length;
    
    res.json({ 
      unreadCount,
      totalThreads: threads.length,
      timestamp: Date.now()
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/me', async (req, res) => {
  try {
    const user = await ig.user.info(ig.state.cookieUserId);
    res.json({ 
      userId: ig.state.cookieUserId,
      username: user.username 
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Helper functions for watch optimization
function getMessageDisplayText(msg) {
  const maxLength = 60; // Shorter for watch display
  
  switch (msg.item_type) {
    case 'text':
      return msg.text.length > maxLength ? msg.text.substring(0, maxLength - 3) + '...' : msg.text;
    case 'media':
      const mediaType = msg.media?.media_type === 1 ? 'Photo' : 'Video';
      return msg.text ? `${mediaType}: ${msg.text.substring(0, 40)}` : mediaType;
    case 'voice_media':
      return `Voice (${Math.round(msg.voice_media?.duration || 0)}s)`;
    case 'like':
      return '❤️';
    default:
      return msg.text?.substring(0, maxLength) || `[${msg.item_type}]`;
  }
}

function getMessageIcon(itemType) {
  const icons = {
    'text': '💬',
    'media': '📷',
    'voice_media': '🎵',
    'raven_media': '👻',
    'link': '🔗',
    'like': '❤️',
    'action_log': '📝'
  };
  return icons[itemType] || '❓';
}

(async () => {
  await login();
  const port = process.env.PORT || 3000;
  app.listen(port, () => console.log(`🚀 Server running on http://localhost:${port}`));
})();
