// App.pq_confirm = App.cable.subscriptions.create("PqConfirmChannel", {
//   connected: function() {
//     // Called when the subscription is ready for use on the server
//   },

//   disconnected: function() {
//     // Called when the subscription has been terminated by the server
//   },

//   received: function(data) {
//     // Called when there's incoming data on the websocket for this channel
//     $('#pq-ids input').each(function (index, input){
//       if (input.value === data.pq_transaction_id) {
//         $('#pq-notification').html('<div class="alert alert-success animated bounceIn">Votre paiment a bien été enregistré.</div>')
//       }
//     });
//   }
// });
