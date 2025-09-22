let chatInput = document.getElementById('chat-input');
let chatMessages = document.getElementById('chat-messages');
let chatSuggestions = document.getElementById('chat-suggestions');

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