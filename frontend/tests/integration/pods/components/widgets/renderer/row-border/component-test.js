import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('widgets/renderer/row-border', 'Integration | Component | widgets/renderer/row border', {
  integration: true
});

test('it renders', function(assert) {
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });

  this.render(hbs`{{widgets/renderer/row-border}}`);

  assert.equal(this.$().text().trim(), '');

  // Template block usage:
  this.render(hbs`
    {{#widgets/renderer/row-border}}
      template block text
    {{/widgets/renderer/row-border}}
  `);

  assert.equal(this.$().text().trim(), 'template block text');
});
