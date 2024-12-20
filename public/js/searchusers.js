document.getElementById('search-input').addEventListener('input', function() {
    const query = this.value;

    if (query.length >= 3) {
        
        document.getElementById('loading-indicator').classList.remove('d-none');

        fetch(`/profile/search/results?query=${query}`)
            .then(response => response.json())
            .then(data => {
                const userList = document.getElementById('user-list');
                userList.innerHTML = ''; 
                document.getElementById('loading-indicator').classList.add('d-none'); 

                if (data.length === 0) {
                    userList.innerHTML = '<li class="list-group-item">Nenhum resultado encontrado</li>';
                }

                data.forEach(user => {
                    const userItem = document.createElement('li');
                    userItem.classList.add('list-group-item', 'd-flex', 'justify-content-between', 'align-items-center');
                    userItem.innerHTML = `
                        <a href="/profile/${user.username}" class="text-decoration-none text-dark">
                            <strong>${user.name}</strong>
                        </a>
                        <span class="badge" style="background-color: #0056b3; color: white;">${user.username}</span>
                    `;
                    userList.appendChild(userItem);
                });
            })
            .catch(error => {
                console.error('Erro:', error);
                document.getElementById('loading-indicator').classList.add('d-none');
            });
    } else {
        document.getElementById('user-list').innerHTML = '';
        document.getElementById('loading-indicator').classList.add('d-none');
    }
});
