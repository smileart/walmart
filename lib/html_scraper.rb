# frozen_string_literal: true
class HtmlScraper
  SELECTOR_TYPES = {
    css: :css,
    xpath: :xpath,
    regexp: :scan
  }

  def parse(html: '', stencils: {}, &final_touch)
    result = Hash.new(nil)

    stencils.each_pair do |name, stencil|
      # if Stencil is a Hash and selector was provided
      if stencil.respond_to?(:has_key?) && stencil.has_key?(:selector)

        # parse node (HTML) and present results as an Array
        preliminary_result = parse_node(html, stencil[:selector]).to_a

        # cast node to string if we've got just one result
        preliminary_result = handle_single_result(preliminary_result, stencil)

        # recursively parse children if stencil contain children section
        preliminary_result = handle_children(preliminary_result, stencil)

        # yield all the callbacks for parsed nodes
        preliminary_result = handle_callbacks(preliminary_result, stencil)

        result[name] = preliminary_result
      end
    end

    # put finishing touches to your data
    result = final_touch.call(result) if block_given?

    result
  end

  private

  def parse_node(node, selector = '')
    selector_type, selector = handle_selector(selector)

    if selector_type
      if node.respond_to?(selector_type)
        return node.send(selector_type, selector)
      elsif node.to_s.respond_to?(selector_type)
        return node.to_s.send(selector_type, selector)
      else
        raise NotImplementedError, "#{selector_type} should be implemented for #{@node.class}"
      end
    end
  end

  def handle_single_result(node, stencil)
    if node.count == 1 && !stencil.has_key?(:children)
      node = node[0].to_s
    end

    node
  end

  def handle_callbacks(node, stencil)
    node = node.dup

    # if we have more tan one result
    if node.respond_to?(:each)
      # apply a callback to each (if provided)
      if stencil[:callback] && stencil[:callback].respond_to?(:call)
        node.map!{|pr| stencil[:callback].call(pr)}.reject!(&:nil?)
      end
    else # if we've got one result
      # call a callback (if provided)
      if stencil[:callback] && stencil[:callback].respond_to?(:call)
        node = stencil[:callback].call(node)
      end
    end

    node
  end

  def handle_children(node, stencil)
    if stencil.has_key?(:children)
      children = []

      node.each do |n|
        children << parse(html: n, stencils: stencil[:children])
      end

      node = children
    end

    node
  end

  def handle_selector(selector)
    sel = selector.scan(/\[(#{SELECTOR_TYPES.keys.map(&:to_s).join('|')})\]\s(.*$)/)
    return if sel.empty?

    sel_type = sel[0][0].to_sym
    sel_type = SELECTOR_TYPES[sel_type] if SELECTOR_TYPES.keys.include?(sel_type)

    return unless sel_type

    if sel_type == :scan
      sel = Regexp.new(sel[0][1], 'ix')
    else
      sel = sel[0][1]
    end

    return sel_type, sel
  end
end


if __FILE__ == $0
end
