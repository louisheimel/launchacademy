var inventory;

(function() {
  inventory = {
    collection: [],
    setDate: function() {
      var now = new Date().toJSON().slice(0, 10);
      $("#order_date").append(now);
    },
    getCachedElement: function() {
      this.template = $("#inventory_item").remove().html();
    },
    incrementedCount: 1,
    addItem: function() {
      var that = this;
      $("#inventory").append(that.template.replace(/ID/g, that.incrementedCount));
      this.collection.push({
        id: that.incrementedCount,
        name: "",
        stockNumber: "",
        quantity: 1,
      });
      this.incrementedCount++;
    },
    deleteRowAt: function(i) {
      this.collection.splice(i - 1, 1);
      $('table tr').eq(i - 1).remove();
    },
    init: function() {
      var that = this;
      this.getCachedElement();
      this.setDate();
      $("#add_item").on("click", function() {
        that.addItem();
      });


      $("#inventory").on("click", "a", function() {
        var current_index = $(this).closest('tr').index() + 1;
        that.deleteRowAt(current_index);
      })


    }
  };

})();

$(inventory.init.bind(inventory));
