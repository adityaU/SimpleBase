import Ember from 'ember';
import UtilsFunctions from "frontend/mixins/utils-functions";

var get = Ember.get,
    arrayComputed = Ember.arrayComputed;
export default Ember.Component.extend( UtilsFunctions,{
    didInsertElement(){
        this.get('getData')(this)
    },
    data: Ember.observer('jsonData', 'type', 'xLabel', 'yLable', 'title', function(){
        this.get('getData')(this)
    }),
    getData(_this){
        let gd = _this.get('getNode')(_this)
        let gridParent = _this.get("gridParent")
        var data =  _this.get('jsonData'), layout;
        data = data && data.map((item, i)=>{
            return  {
                x: item.get('contents').sortBy('x1').map((el)=>{ return el.get('displayX1')}),
                y:  item.get('contents').sortBy('x1').map((el)=>{ return el.get('displayY')}),
                type: 'scatter',
                mode: 'lines+markers',
                line: {
                    width: 1.3,
                    color: _this.get('colors')[i]
                },
                name:  item.get('type')
            }
        });
        layout = data && _this.get('layout')
        data && Plotly.newPlot(gd, data, layout, {showLine: false})
            .then(_this.get('downloadAsPNG')); 
        data && gridParent[0] && gridParent[0].addEventListener('plotlyResize', function() {
            let dimensions = _this.get('dimensions')(gridParent) 
            Plotly.relayout(_this.get("randomId"), dimensions)
        });
    }
});
