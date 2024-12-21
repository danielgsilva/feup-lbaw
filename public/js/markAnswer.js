function sendDataAjaxRequest(method, url, data, handleResponse) {
    let dataJson = JSON.stringify(data);
    fetch(url, {
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'X-Request-With': "XMLHttpRequest",
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content,
            },
            method: method,
            credentials: 'same-origin',
            body: dataJson
        },
    ).then(response => response.json()).then(json => handleResponse(json));
}

function markAcceptedHandler(json) {
    let element = document.querySelector(".accepted-icon-" + json.id_answer);
    let text = document.querySelector('.mark-accepted-' + json.id_answer)
    if(json.accepted) {
        element.innerHTML = '<i class="fa-solid fa-check"></i>';
        text.innerHTML = 'Unmark as accepted';
    } else {
        element.innerHTML = '';
        text.innerHTML = 'Mark as accepted';
    }
}

function markAcceptedAnswer(id_answer) {
    let data = {
        'id_answer': id_answer,
    };

    sendDataAjaxRequest('POST', '/answers/' + id_answer + '/accept', data, markAcceptedHandler);
}

function markAsAcceptedListener(){
    let answers = document.querySelectorAll('.answer-question-card');
    for (let i = 0; i < answers.length; i++) {
        if (answers[i].querySelector('.mark-accepted')) {
            let id_answer = answers[i].querySelector(".answer-id").value;
            document.querySelector('.mark-accepted-' + id_answer).addEventListener('click', function() { markAcceptedAnswer(id_answer); });
        }
    }
}

markAsAcceptedListener();