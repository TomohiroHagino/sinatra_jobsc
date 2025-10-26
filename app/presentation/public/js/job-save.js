// フラッシュメッセージを表示する関数
function showFlashMessage(message, type = 'success') {
    const flashContainer = document.getElementById('flash-container');
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type} alert-dismissible fade show`;
    alertDiv.setAttribute('role', 'alert');
    alertDiv.innerHTML = `
        <i class="fas fa-${type === 'success' ? 'check-circle' : 'exclamation-triangle'}"></i> ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    
    flashContainer.appendChild(alertDiv);
    
    // 5秒後に自動で消す
    setTimeout(() => {
        alertDiv.classList.remove('show');
        setTimeout(() => alertDiv.remove(), 150);
    }, 5000);
}

// 保存ボタンのフォーム送信をAJAX化
document.addEventListener('DOMContentLoaded', function() {
    const forms = document.querySelectorAll('form[action="/jobs"]');
    
    forms.forEach(form => {
        form.addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const button = form.querySelector('button[type="submit"]');
            const originalButtonText = button.innerHTML;
            button.disabled = true;
            button.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 保存中...';
            
            try {
                const formData = new FormData(form);
                const response = await fetch('/jobs', {
                    method: 'POST',
                    headers: {
                        'X-Requested-With': 'XMLHttpRequest'
                    },
                    body: formData
                });
                
                const result = await response.json();
                
                if (result.success) {
                    showFlashMessage(result.message, 'success');
                    button.innerHTML = '<i class="fas fa-check"></i> 保存済み';
                    button.classList.remove('save-btn');
                    button.classList.add('btn-secondary');
                    
                    // 3秒後にボタンを元に戻す
                    setTimeout(() => {
                        button.innerHTML = originalButtonText;
                        button.classList.remove('btn-secondary');
                        button.classList.add('save-btn');
                        button.disabled = false;
                    }, 3000);
                } else {
                    showFlashMessage(result.message || 'エラーが発生しました', 'danger');
                    button.disabled = false;
                    button.innerHTML = originalButtonText;
                }
            } catch (error) {
                showFlashMessage('通信エラーが発生しました', 'danger');
                button.disabled = false;
                button.innerHTML = originalButtonText;
            }
        });
    });
});

