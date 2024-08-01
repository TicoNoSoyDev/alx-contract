new Vue({
    el: '#app',
    methods: {
        aceptar() {
            fetch('https://alx-contract/accept', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                }
            }).then(response => response.json()).then(data => {
                console.log('ACEPTAR button clicked');
                hideui() // Hide the interface after clicking ACCEPT
            });
        },
        cancelar() {
            fetch('https://alx-contract/cancel', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                }
            }).then(response => response.json()).then(data => {
                
                console.log('CANCELAR button clicked');
                hideui()
                 // Hide the interface
                // this.hideInterface(); // Hide the interface after clicking CANCEL
            });
        },
    },
    mounted() {
        window.addEventListener('message', (event) => {
            if (event.data.type === 'open') {
                var interact = document.getElementById("interaction-box")
                document.body.style.display = 'flex'; // Show the interface
                console.log("abrir")
                setTimeout(() => {
                    interact.classList.remove("inactive");
                }, 10);

            }
        });
    }
});


function hideui() {
    var interact = document.getElementById("interaction-box")
    interact.classList.add("inactive");

    setTimeout(() => {
        document.body.style.display = 'none';
    }, 500);
}
