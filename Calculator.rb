require 'java'

module Swing
  include_package 'java.awt'
  include_package 'javax.swing'
end

module AwtEvent
  include_package 'java.awt.event'
end

$numListener = AwtEvent::ActionListener.new
def $numListener.actionPerformed (event)
  comm = event.getActionCommand
  $calculator.setExpression($calculator.getExpression + comm) if comm != "="
  $calculator.setExpression(eval($calculator.getExpression).to_s) if comm == "="
end

$fnListener = AwtEvent::ActionListener.new
def $fnListener.actionPerformed (event)
    val = $calculator.getExpression.to_f
    fn = $calculator.getFnForName(event.getActionCommand)
    $calculator.setExpression(fn.call(val).to_s)
end

$calculator = Swing::JFrame.new
class << $calculator

  def init
    cp = getContentPane
    
    # field for entering expression
    exprPanel = Swing::JPanel.new(Swing::BorderLayout.new)
    
    exprBox = Swing::Box.new(Swing::BoxLayout::X_AXIS)
    exprBox.add(Swing::Box::createHorizontalGlue)
    exprBox.add(Swing::JLabel.new("Enter an expression: "))

    @exprField = Swing::JTextField.new(20)
    exprBox.add(Swing::Box::createHorizontalStrut(4))
    exprBox.add(@exprField)
    exprBox.add(Swing::Box::createHorizontalGlue)

    exprPanel.add(Swing::BorderLayout::NORTH, exprBox)
    cp.add(Swing::BorderLayout::NORTH, exprPanel)

    # формируем и добавляем цифровую клавиатуру
    buttons = [
      '7', '8', '9', '/',
      '4', '5', '6', '*',
      '1', '2', '3', '-',
      '0', '.', '=', '+'
    ]
    numPadPanel = Swing::JPanel.new(Swing::GridLayout.new(4, 4))

    buttons.each { |symbol|
      numPadButton = Swing::JButton.new(symbol)
      numPadButton.setActionCommand(symbol)
      numPadButton.addActionListener($numListener)
      numPadPanel.add(numPadButton)
    }

    cp.add(numPadPanel, Swing::BorderLayout::CENTER)

    # формируем и добавляем панель функций
    @fnMap = {
      'sin'  => proc { |n| Math::sin(n * Math::PI / 180) },
      'cos'  => proc { |n| Math::cos(n * Math::PI / 180) },
      'ln'   => proc { |n| Math::log(n) },
      'sqrt' => proc { |n| Math::sqrt(n) }
    }

    fnPanel = Swing::JPanel.new(Swing::GridLayout.new(1, 4))
    @fnMap.each_key { | fnName |
      fnButton = Swing::JButton.new(fnName)
      fnButton.setActionCommand(fnName)
      # мы напишем $fnListener momentarily – который полностью 
      # соответствует только что описанному $numPadListener
      fnButton.addActionListener($fnListener)
      fnPanel.add(fnButton)
    }

    cp.add(fnPanel, Swing::BorderLayout::SOUTH)
  end

  def setExpression (expr)
    @exprField.setText(expr)
  end

  def getExpression
    @exprField.getText
  end

  def getFnForName (name)
    @fnMap[name]
  end

end

$calculator.init
$calculator.setSize(400, 400)
$calculator.setVisible(true)

