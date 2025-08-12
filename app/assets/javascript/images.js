$(document).on('turbo:load', function () {
        $(document).on('click', '#process-img', function(event) {
            let $img_id = $(event.target).data('id');
            let operation = $(event.target).data('operation');
            $.ajax({
                url: "/images/process_img",
                method: "GET",
                dataType: "json",
                data: {
                    process_name: operation,
                    image_id: $(event.target).data('id')
                },
                success: function(response) {
                    if (response.status === 202) {
                        let $bg_status = $('[data-bg-id="' + $img_id + '"]')
                        $bg_status
                            .addClass('bg-warning')
                            .removeClass('bg-success')
                            .text('Processando');

                        Swal.fire({
                        icon: "success",    
                        title: "GG",
                        text: `Worker adicionado na fila, sera executado daqui a ${response.time}`
                        });
                    } else {
                        Swal.fire({
                        icon: "error",    
                        title: "ABALO",
                        text: response.message || `Algo deu errado` 
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
});
