function addEventListeners() {
  let toggleCommentsButton = document.getElementById('toggle-comments');
  if (toggleCommentsButton) {
    toggleCommentsButton.addEventListener('click', toggleComments);
  }

  let toggleOrderButton = document.getElementById('toggle-order');
  if (toggleOrderButton) {
    toggleOrderButton.addEventListener('click', toggleOrder);
  }

  let toggleOrderQuestionsButton = document.getElementById('toggle-order-questions');
  if (toggleOrderQuestionsButton) {
    toggleOrderQuestionsButton.addEventListener('click', toggleOrderQuestions);
  }

  let toggleAnswerFormButton = document.getElementById('toggle-answer-form');
  if (toggleAnswerFormButton) {
    toggleAnswerFormButton.addEventListener('click', toggleAnswerForm);
  }
}

function encodeForAjax(data) {
  if (data == null) return null;
  return Object.keys(data).map(function(k) {
    return encodeURIComponent(k) + '=' + encodeURIComponent(data[k]);
  }).join('&');
}

function sendAjaxRequest(method, url, data, handler) {
  let request = new XMLHttpRequest();

  request.open(method, url, true);
  request.setRequestHeader('X-CSRF-TOKEN', document.querySelector('meta[name="csrf-token"]').content);
  request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
  request.addEventListener('load', handler);
  request.send(encodeForAjax(data));
}

function toggleOrder() {
  const toggleOrderButton = document.getElementById('toggle-order');
  const currentOrder = toggleOrderButton.dataset.order;
  const newOrder = currentOrder === 'votes' ? 'date' : 'votes';
  const url = new URL(window.location.href);
  url.searchParams.set('order', newOrder);
  window.location.href = url.toString();
}

function toggleComments() {
  const commentsSection = document.getElementById('comments-section');
  if (commentsSection.style.display === 'none') {
    commentsSection.style.display = 'block';
    this.textContent = 'Hide Comments';
  } else {
    commentsSection.style.display = 'none';
    this.textContent = 'Show Comments';
  }
}

function toggleOrderQuestions() {
  const currentOrder = document.getElementById('toggle-order-questions').dataset.order;
  const newOrder = currentOrder === 'votes' ? 'date' : 'votes';
  const url = new URL(window.location.href);
  url.searchParams.set('order', newOrder);
  window.location.href = url.toString();
}

function toggleAnswerForm() {
  const answerForm = document.getElementById('answer-form');
  if (answerForm.style.display === 'none') {
    answerForm.style.display = 'block';
  } else {
    answerForm.style.display = 'none';
  }
}

addEventListeners();
