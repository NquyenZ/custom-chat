let chatInput = document.getElementById('chat-input');
let chatMessages = document.getElementById('chat-messages');
let chatSuggestions = document.getElementById('chat-suggestions');
let chatBubbles = document.getElementById("chat-bubbles");

let commandHistory = [];
let historyIndex = 0;

function addMessageToChat(msg)
{
    let div = document.createElement('div');

    div.classList.add('chat-message');
    div.innerHTML = msg.replace(/{([0-9A-Fa-f]{6})}/g, (_, color) => `<span style="color:#${color}">`) + "</span>";

    chatMessages.appendChild(div);
    chatMessages.scrollTop = chatMessages.scrollHeight;
}

function scrollToBottom()
{
    chatMessages.scrollTop = chatMessages.scrollHeight;
}

function openChat()
{
    chatMessages.classList.add("active");
    chatInput.style.display = "block";
    chatInput.focus();
}

function closeChat()
{
    chatMessages.classList.remove("active");
    chatInput.style.display = "none";
    chatInput.value = "";

    scrollToBottom()
}

window.addEventListener('message', (event) =>
{
    const data = event.data;

    if(data.action === 'enableInput')
    {
        openChat()

        chatInput.style.display = 'block';
        chatInput.focus();
    }

    if(data.action === 'disableInput')
    {
        closeChat()

        chatInput.style.display = 'none';

        if(data.clear)
        {
            chatInput.value = '';
        }

        chatSuggestions.style.display = 'none';
    }

    if(data.action === 'addMessage')
    {
        let div = document.createElement('div');

        div.classList.add('chat-message');
        div.innerHTML = data.message.replace(/{([0-9A-Fa-f]{6})}/g, (_, color) => `<span style="color:#${color}">`) + "</span>";
        
        chatMessages.appendChild(div);
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }

    if(data.action === 'clearChat')
    {
        chatMessages.innerHTML = '';
    }

    if(data.action === 'updateSuggestions')
    {
        const suggestions = data.suggestions;

        if(suggestions.length > 0)
        {
            chatSuggestions.innerHTML = '';

            suggestions.forEach(cmd =>
            {
                let div = document.createElement('div');

                div.textContent = cmd;
                div.onclick = () => { chatInput.value = cmd; chatInput.focus(); };

                chatSuggestions.appendChild(div);
            });
            
            chatSuggestions.style.display = 'block';
        }
        else
        {
            chatSuggestions.style.display = 'none';
        }
    }

    if(data.action === "showChatBubble")
    {
        const id = `bubble-${data.serverId}`;
        let bubble = document.getElementById(id);

        if(!bubble)
        {
            bubble = document.createElement("div");
            bubble.classList.add("chat-bubble");
            bubble.id = id;
            bubble.dataset.serverId = data.serverId;

            chatBubbles.appendChild(bubble);
        }

        let msg = data.text
            .replace(/{([0-9A-Fa-f]{6})}/g, (_, color) => `<span style="color:#${color}">`)
            .replace(/{end}/g, "</span>");

        bubble.innerHTML = msg;

        if(data.color)
        {
            const a = (typeof data.color.a === 'number') ? (data.color.a / 255) : 1;

            bubble.style.color = `rgba(${data.color.r}, ${data.color.g}, ${data.color.b}, ${a})`;
        }
        else
        {
            bubble.style.color = "";
        }

        const updatePosition = () =>
        {
            const x = (data.screen && typeof data.screen.x === 'number') ? data.screen.x : 0.5;
            const y = (data.screen && typeof data.screen.y === 'number') ? data.screen.y : 0.5;

            bubble.style.left = `${x * 100}%`;
            bubble.style.top = `${y * 100}%`;
        };

        updatePosition();

        bubble.style.opacity = 1;

        if(bubble._removeTimeout)
        {
            clearTimeout(bubble._removeTimeout);
        }

        bubble._removeTimeout = setTimeout(() =>
        {
            bubble.classList.add('fade-out');
            bubble._removeTimeout2 = setTimeout(() =>
            {
                if(bubble && bubble.parentElement)
                {
                    bubble.parentElement.removeChild(bubble);
                }
            }, 300);
        }, data.time || 5000);
    }

    if(event.data.action === "removeChatBubble")
    {
        const serverId = event.data.serverId;
        const bubble = document.getElementById(`bubble-${serverId}`);

        if(bubble)
        {
            if(bubble._removeTimeout)
            {
                clearTimeout(bubble._removeTimeout);
                
                bubble._removeTimeout = null;
            }

            if(bubble._removeTimeout2)
            {
                clearTimeout(bubble._removeTimeout2);
                bubble._removeTimeout2 = null;
            }

            bubble.classList.add('fade-out');

            setTimeout(() =>
            {
                if(bubble && bubble.parentElement)
                {
                    bubble.parentElement.removeChild(bubble);
                }
            }, 300);
        }
    }

    if(data.action === "hideChatMessages")
    {
        document.getElementById('chat-messages').style.display = "none";
    }

    if(data.action === "showChatMessages")
    {
        document.getElementById('chat-messages').style.display = "flex";
    }
});

chatInput.addEventListener('keydown', (e) =>
{
    if(e.key === 'Enter')
    {
        if(chatInput.value.length > 0)
        {
            commandHistory.push(chatInput.value);

            historyIndex = commandHistory.length;
        }

        fetch(`https://${GetParentResourceName()}/sendMessage`,
        {
            method:'POST',
            body: JSON.stringify({ message: chatInput.value }),
            headers:{ 'Content-Type':'application/json' }
        });
    }
    else if(e.key === 'Escape')
    {
        fetch(`https://${GetParentResourceName()}/closeInput`, { method:'POST' });
    }
    else if(e.key === 'ArrowUp')
    {
        if(historyIndex > 0)
        {
            historyIndex--;
        }
        
        chatInput.value = commandHistory[historyIndex] || '';
        chatInput.setSelectionRange(chatInput.value.length, chatInput.value.length);
        
        e.preventDefault();
    }
    else if(e.key === 'ArrowDown')
    {
        if(historyIndex < commandHistory.length - 1)
        {
            historyIndex++;
            chatInput.value = commandHistory[historyIndex] || '';
        }
        else
        {
            historyIndex = commandHistory.length;
            chatInput.value = '';
        }

        chatInput.setSelectionRange(chatInput.value.length, chatInput.value.length);

        e.preventDefault();
    }
    else
    {
        if(chatInput.value.startsWith('/'))
        {
            fetch(`https://${GetParentResourceName()}/getSuggestions`,
            {
                method:'POST',
                body: JSON.stringify({ input: chatInput.value.slice(1) }),
                headers:{ 'Content-Type':'application/json' }
            });
        }
        else
        {
            chatSuggestions.style.display = 'none';
        }
    } 
});