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

  let toggleCommentFormButton = document.getElementById('toggle-comment-form');
  if(toggleCommentFormButton) {
    toggleCommentFormButton.addEventListener('click', toggleCommentForm);
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
  const commentForm = document.getElementById('comment-form');

  if (answerForm.style.display === 'none') {
    answerForm.style.display = 'block';
    if (commentForm) commentForm.style.display = 'none';
  } else {
    answerForm.style.display = 'none';
  }
}

function toggleCommentForm() {
  const commentForm = document.getElementById('comment-form');
  const answerForm = document.getElementById('answer-form');

  if (commentForm.style.display === 'none') {
    commentForm.style.display = 'block';
    if (answerForm) answerForm.style.display = 'none';
  } else {
    commentForm.style.display = 'none';
  }
}

addEventListeners();

document.addEventListener('DOMContentLoaded', function () {
  var toastElList = [].slice.call(document.querySelectorAll('.notification-toast'));
  var toastList = toastElList.map(function (toastEl) {
      return new bootstrap.Toast(toastEl, {
          autohide: true
      });
  });
  toastList.forEach(toast => toast.show());
});

document.addEventListener('DOMContentLoaded', function () {
  const pusher = new Pusher(window.PUSHER_APP_KEY, {
      cluster: window.PUSHER_APP_CLUSTER,
      encrypted: true
  });

  const channel = pusher.subscribe('notifications');
  channel.bind('notification-read', function(data) {
      showModal(data.message);
  });
});

function showModal(message) {
  if (document.querySelector('.modal.show')) {
    return; 
  }

  // Create the modal HTML structure
  const modalHTML = `
    <div class="modal fade" id="notificationModal" tabindex="-1" aria-labelledby="notificationModalLabel" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="notificationModalLabel">New Notification</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            ${message}
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          </div>
        </div>
      </div>
    </div>
  `;

  document.body.insertAdjacentHTML('beforeend', modalHTML);

  const modalElement = document.getElementById('notificationModal');

  const modal = new bootstrap.Modal(modalElement);

  modal.show();

  modalElement.addEventListener('hidden.bs.modal', function () {
    modalElement.remove(); 
  });
}