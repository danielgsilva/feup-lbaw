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
/*
document.addEventListener('DOMContentLoaded', function () {
  var toastElList = [].slice.call(document.querySelectorAll('.notification-toast'));
  var toastList = toastElList.map(function (toastEl) {
      return new bootstrap.Toast(toastEl, {
          autohide: true
      });
  });
  toastList.forEach(toast => toast.show());
});
*/

function showToast(notification) {
    if (!notification) {
        console.error("Notification is undefined");
        return;
    }

    console.log("showToast called with notification:", notification);

    // Create the toast HTML structure
    const toastHTML = `
        <div class="toast notification-toast position-fixed bottom-0 end-0 p-2 me-2" id="notification-toast" role="alert" aria-live="assertive" aria-atomic="true" style="z-index: 1055;">
            <div class="toast-header">
                <strong class="me-auto">Notification</strong>
                <small class="text-muted">${new Date().toLocaleString()}</small>
                <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
            <div class="toast-body">
                ${notification.message}
                <p>Go to your notification page to see more</p>
            </div>
        </div>
    `;

    console.log("Showing toast:", toastHTML);

    document.body.insertAdjacentHTML('beforeend', toastHTML);

    const toastElement = document.getElementById("notification-toast");
    console.log("Toast element:", toastElement);

    if (!toastElement) {
        console.error("Toast element not found");
        return;
    }

    const toast = new bootstrap.Toast(toastElement, { autohide: true, delay:5000 });

    toast.show();

    toastElement.addEventListener('hidden.bs.toast', function () {
        toastElement.remove();
    });
}

// Existing code to initialize Pusher and subscribe to the channel
const pusher = new Pusher(window.PUSHER_APP_KEY, {
    cluster: window.PUSHER_APP_CLUSTER,
    encrypted: true,
    forceTLS: true,
    authEndpoint: '/broadcasting/auth',
    auth: {
        headers: {
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content,
        },
    },
});

const channel = pusher.subscribe("notifications." + window.userId);
console.log("Subscribing to channel:", 'notifications.' + window.userId);

channel.bind("notification-received", function(e) {
    console.log("notification received");
    console.log(e);
    showToast(e);
});

console.log("Active Subscriptions:", pusher.channels);