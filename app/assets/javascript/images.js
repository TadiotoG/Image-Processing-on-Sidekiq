$(document).on('click', '#process-img', function() {
    $(event.target).data('id');
    let operation = $(event.target).data('operation');
    $.ajax({
        url: "images/process_img",
        method: "GET",
        dataType: "json",
        data: {
            process_name: operation,
            image_id: $(event.target).data('id')
        },
        success: function(response) {
            if (response.status === 200) {
                Swal.fire({
                icon: "success",    
                title: "GG",
                text: `Sua operação FUNCIONOU!`
                });
            } else {
                Swal.fire({
                icon: "error",    
                title: "ABALO",
                text: `Algo deu errado`
                });
            }
        },
        error: function() {
            Swal.fire({
                icon: "error",    
                title: "ABALO",
                text: `Algo deu errado`
            });
        }
    });
});
