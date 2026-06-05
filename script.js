const feedList = document.getElementById('feed-list');
const postForm = document.getElementById('post-form');
const postMessage = document.getElementById('post-message');
const postHint = document.getElementById('post-hint');
const loginButton = document.getElementById('login-button');
const logoutButton = document.getElementById('logout-button');
const userInfo = document.getElementById('user-info');
const userNameEl = document.getElementById('user-name');
const loginModal = document.getElementById('login-modal');
const loginForm = document.getElementById('login-form');
const loginUsername = document.getElementById('login-username');
const loginPassword = document.getElementById('login-password');
const loginClose = document.getElementById('login-close');

const STORAGE_KEY = 'republicaEsperanzaUser';
const initialPosts = [
  {
    author: 'María González',
    date: 'Hoy, 09:15',
    text: 'Organizamos una jornada de limpieza en el parque central este sábado. ¡Todos invitados a participar!'
  },
  {
    author: 'Grupo de Huerto',
    date: 'Ayer, 18:30',
    text: 'Buscamos voluntarios para diseñar un jardín comunitario con plantas comestibles. Contáctanos si quieres ayudar.'
  },
  {
    author: 'José Rivera',
    date: '2 días',
    text: 'Se abrió un espacio para intercambiar libros y herramientas. Trae lo que ya no uses y llévate algo nuevo.'
  }
];

function renderFeed(posts) {
  feedList.innerHTML = posts
    .map(post => `
      <article class="feed-card">
        <time datetime="2026-01-01">${post.date}</time>
        <p><strong>${post.author}</strong></p>
        <p>${post.text}</p>
      </article>
    `)
    .join('');
}

function setPostState(enabled) {
  postForm.classList.toggle('disabled', !enabled);
  postMessage.disabled = !enabled;
  postForm.querySelector('button').disabled = !enabled;
  postHint.textContent = enabled
    ? 'Tienes acceso para publicar en el muro comunitario.'
    : 'Inicia sesión para publicar en el muro.';
}

function updateAuthState() {
  const storedUser = localStorage.getItem(STORAGE_KEY);
  const isLogged = Boolean(storedUser);

  loginButton.classList.toggle('hidden', isLogged);
  userInfo.classList.toggle('hidden', !isLogged);

  if (isLogged) {
    userNameEl.textContent = storedUser;
  } else {
    userNameEl.textContent = '';
  }

  setPostState(isLogged);
}

function openLoginModal() {
  loginModal.classList.remove('hidden');
  loginModal.setAttribute('aria-hidden', 'false');
  loginUsername.focus();
}

function closeLoginModal() {
  loginModal.classList.add('hidden');
  loginModal.setAttribute('aria-hidden', 'true');
}

function setUser(username) {
  localStorage.setItem(STORAGE_KEY, username);
  updateAuthState();
}

function logoutUser() {
  localStorage.removeItem(STORAGE_KEY);
  updateAuthState();
}

function handleLogin(event) {
  event.preventDefault();
  const username = loginUsername.value.trim();
  const password = loginPassword.value.trim();

  if (!username || !password) {
    alert('Por favor, completa nombre y contraseña para iniciar sesión.');
    return;
  }

  setUser(username);
  loginForm.reset();
  closeLoginModal();
}

function handleOutsideClick(event) {
  if (event.target === loginModal) {
    closeLoginModal();
  }
}

function addPost(event) {
  event.preventDefault();
  if (!localStorage.getItem(STORAGE_KEY)) {
    alert('Debes iniciar sesión para publicar en el muro.');
    return;
  }

  const text = postMessage.value.trim();
  if (!text) return;

  const newPost = {
    author: localStorage.getItem(STORAGE_KEY) || 'Tú',
    date: 'Ahora mismo',
    text
  };

  initialPosts.unshift(newPost);
  renderFeed(initialPosts);
  postMessage.value = '';
  postMessage.focus();
}

loginButton.addEventListener('click', openLoginModal);
logoutButton.addEventListener('click', logoutUser);
loginClose.addEventListener('click', closeLoginModal);
loginModal.addEventListener('click', handleOutsideClick);
loginForm.addEventListener('submit', handleLogin);
postForm.addEventListener('submit', addPost);

renderFeed(initialPosts);
updateAuthState();
